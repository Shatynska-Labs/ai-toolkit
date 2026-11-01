import re,os,html,sys,subprocess as sp,tempfile,tarfile,io,glob,json,time
D,R,title=sys.argv[1:4]
g=lambda *a:sp.run(['git','-C',R,*a],capture_output=True,text=True).stdout
t0=time.time()
sp.run(['git','-C',R,'fetch','--quiet','--no-prune','origin'])
T=tempfile.mkdtemp()
tar=sp.run(['git','-C',R,'archive','origin/main','docs/backlog','docs/workstreams','openspec/changes'],capture_output=True).stdout
tarfile.open(fileobj=io.BytesIO(tar)).extractall(T)
sha=g('rev-parse','--short','origin/main').strip()
archived={re.sub(r'^\d{4}-\d\d-\d\d-','',os.path.basename(x)) for x in glob.glob(T+'/openspec/changes/archive/*')}
openc={os.path.basename(x) for x in glob.glob(T+'/openspec/changes/*') if os.path.isdir(x) and not x.endswith('/archive')}
local=set(g('for-each-ref','--format=%(refname:short)','refs/heads').split())
remote={l.split('refs/heads/')[1] for l in g('ls-remote','--heads','origin').splitlines()}
branches=(local|remote)-{'main','master'}
prs=json.loads(sp.run(['gh','pr','list','--state','all','--limit','5000','--json','headRefName,state'],cwd=R,capture_output=True,text=True).stdout)
merged={p['headRefName'] for p in prs if p['state']=='MERGED'}; opr={p['headRefName'] for p in prs if p['state']=='OPEN'}
entries={}
for f in glob.glob(T+'/docs/backlog/*.md'):
    n=os.path.basename(f)[:-3]
    if n in('AGENTS','CLAUDE','README'):continue
    s=open(f,encoding='utf8').read(); p=s.split('---\n',2)
    fm,body=(p[1],p[2]) if len(p)==3 else ('',s)
    v=lambda k,d:(re.search(rf'^{k}: *(.+)$',fm,re.M) or [0,d])[1].strip().strip('"')
    entries[n]=dict(ws=v('workstream','none'),pri=v('priority','normal'),summary=v('summary',''),body=body.strip())
def status(n):
    if n in archived or (n not in openc and n in merged): return 'done'
    if n in openc or n in branches or n in opr: return 'flight'
    if n in entries: return 'rec'
    return 'planned'
def ref(n):
    for r in (f'refs/heads/{n}',f'refs/remotes/origin/{n}','origin/main'):
        c=sp.run(['git','-C',R,'cat-file','-e',f'{r}:openspec/changes/{n}/proposal.md'],capture_output=True)
        if c.returncode==0:return r
def stage(n):
    if n in openc and n in merged: return 'ship:merged'
    if n in opr: return 'ship:pr-open'
    r=ref(n)
    if not r: return 'plan:exploring'
    t=g('show',f'{r}:openspec/changes/{n}/tasks.md')
    x=len(re.findall(r'^- \[x\]',t,re.M)); a=x+len(re.findall(r'^- \[ \]',t,re.M))
    return f'build:applying {x}/{a}' if x else 'plan:drafting'
def proposal_ws(n):
    r=ref(n)
    if not r: return ''
    m=re.search(r'^\*\*Workstream\*\*:.*?`([^`]+)`',g('show',f'{r}:openspec/changes/{n}/proposal.md'),re.M)
    return m[1] if m else ''
WS=[];warn=0
for f in sorted(glob.glob(T+'/docs/workstreams/*.md')):
    n=os.path.basename(f)[:-3]
    if n in('AGENTS','CLAUDE','README'):continue
    s=open(f,encoding='utf8').read()
    m=lambda k:(re.search(rf'\*\*{k}\*\*: (.+)',s) or [0,''])[1]
    block=s.split('**Steps**',1)[-1]; block=re.split(r'^(?:- \*\*|## )',block,1,re.M)[0]
    steps=re.findall(r'^\d+\. `([^`]+)` — (.+)$',block,re.M)
    warn+=len(re.findall(r'^\d+\. ',block,re.M))-len(steps)
    WS.append(dict(n=n,goal=m('Goal'),done=m('Done when'),summary=m('Summary'),steps=list(steps),extra=[]))
wsn={w['n'] for w in WS}; placed={x[0]:w['n'] for w in WS for x in w['steps']}
tasks=set(entries)|openc|{b for b in branches|opr if re.fullmatch(r'[a-z0-9]+(-[a-z0-9]+)*',b) and status(b)=='flight'}
none=[];
for n in sorted(tasks-set(placed)):
    pw=proposal_ws(n) if status(n)=='flight' else ''
    ew=entries.get(n,{}).get('ws','none')
    w=pw if pw in wsn else ew if ew in wsn else None
    if w: next(x for x in WS if x['n']==w)['extra'].append(n)
    elif status(n)!='done': none.append(n)
    else: none.append(n)
    if w: placed[n]=w
flight=[n for n in sorted(set(placed)|set(none)) if status(n)=='flight']
stg={n:stage(n) for n in flight}
last={}
cur=None
for l in g('log','--format=%x00%ct','--name-only','origin/main','--','docs/backlog','openspec/changes').splitlines():
    if l.startswith('\0'): cur=int(l[1:]); continue
    m=re.match(r'docs/backlog/([^/]+)\.md$',l) or re.match(r'openspec/changes/archive/\d{4}-\d\d-\d\d-([^/]+)/',l) or re.match(r'openspec/changes/([^/]+)/',l)
    if m and cur: last.setdefault(m[1],cur)
mainsha=g('rev-parse','origin/main').strip()
for l in g('for-each-ref','--format=%(committerdate:unix) %(objectname) %(refname)','refs/heads','refs/remotes/origin').splitlines():
    ts,sha_,rf=l.split(); nm=rf.split('/',3)[-1] if rf.startswith('refs/remotes') else rf[len('refs/heads/'):]
    if sha_!=mainsha and nm not in('main','master','HEAD'): last[nm]=max(last.get(nm,0),int(ts))
NOW=time.time()
def ago(n):
    t=last.get(n)
    if not t: return ''
    d=int(NOW-t)
    if d<3600: v=f'{max(d//60,1)} min'
    elif d<86400: v=f'{d//3600} h'
    elif d<86400*60: v=f'{d//86400} d'
    else: v=f'{d//(86400*30)} mo'
    return v
flight.sort(key=lambda n:-last.get(n,0))
tme=time.time()-t0
src=open(D+'/page-style.html',encoding='utf8').read(); head=src[:src.index('</style>')]
head+='''.ago { font-size: 13px; color: var(--muted); font-variant-numeric: tabular-nums; white-space: nowrap }
.work { grid-template-columns: minmax(0, 1fr) 170px 76px minmax(0, 220px) }
.workhead { padding-block: 8px; font-size: 12px; color: var(--muted) }
.rowgrid { display: grid; grid-template-columns: 96px minmax(0, 1fr) 76px 56px; gap: 10px; align-items: start }
.rowhead { font-size: 12px; color: var(--muted); border-bottom: 1px solid var(--line); padding-bottom: 6px }
ol.steps > li.step, ul.steps > li.step { display: block }
details.task > summary { display: grid; list-style: none }
details.task > summary::after, details[open].task > summary::after { content: none; display: none }
details.task > summary.rowgrid { gap: 10px; align-items: start; flex-wrap: nowrap }
.more { font-size: 12px; color: var(--work); text-decoration: underline; height: 21px; display: inline-flex; align-items: center }
.more::before { content: "details" }
details[open].task .more::before { content: "hide" }
details.task > .full:first-of-type { margin-top: 8px }
details.task > .full { margin-left: 106px }
.ago.cell { height: 21px; display: inline-flex; align-items: center }
@media (max-width: 640px) {
  .work { grid-template-columns: 1fr }
  .workhead, .rowhead { display: none }
  .rowgrid, details.task > summary.rowgrid { grid-template-columns: minmax(0, 1fr) auto auto; gap: 2px 10px }
  .rowgrid > .st { grid-column: 1 / -1 }
  details.task > .full { margin-left: 0 }
}
'''
e=lambda s:html.escape(s,quote=True)
def inline(s):
    s=e(s); s=re.sub(r'`([^`]+)`',r'<code>\1</code>',s); return re.sub(r'\*\*([^*]+)\*\*',r'<strong>\1</strong>',s)
LAB={'done':'done','flight':'in flight','planned':'planned','rec':'recorded'}
CL={'done':'done','flight':'flight','planned':'planned','rec':''}
def row(n,desc=None,un=False):
    s=status(n); st=f'<span class="st {CL[s]}">{LAB[s]}</span>'
    x=f'<span class="stage-inline">{e(stg[n])}</span>' if n in stg else ''
    if entries.get(n,{}).get('pri') not in(None,'normal'): x+=f'<span class="tag" style="margin-left:6px">{e(entries[n]["pri"])}</span>'
    if un: x+='<span class="tag" style="margin-left:6px">unplaced</span>'
    d=f'<p class="desc">{inline(desc)}</p>' if desc else ''
    main=f'<div><span class="name">{e(n)}</span>{x}{d}</div>'
    t=f'<span class="ago cell">{ago(n)}</span>'
    if n in entries:
        b=''.join(f'<p class="full">{inline(l.lstrip("- "))}</p>' for l in entries[n]['body'].split('\n') if l.strip())
        return f'<li class="step"><details class="task"><summary class="rowgrid">{st}{main}{t}<span class="more"></span></summary>{b}</details></li>'
    return f'<li class="step"><div class="rowgrid">{st}{main}{t}<span></span></div></li>'
HEAD='<li class="rowgrid rowhead" aria-hidden="true"><span>Status</span><span>Task</span><span>Last commit</span><span></span></li>'
def wshtml(w):
    cls={'done':'d','flight':'f','planned':'p','rec':''}
    names=[x[0] for x in w['steps']]
    bar=''.join(f'<b class="{cls[status(x)]}"></b>' for x in names)
    dn=sum(status(x)=='done' for x in names); fl=sum(status(x)=='flight' for x in names+w['extra'])
    sm=f'<div class="sub">{inline(w["summary"])}</div>' if w['summary'] else ''
    ex=''.join(row(x,un=True) for x in w['extra'])
    extra=f'<span>{len(w["extra"])} unplaced</span>' if w['extra'] else ''
    return f'''<details class="group" id="{w['n']}"><summary><span class="chev" aria-hidden="true">▶</span><div><div class="name">{w['n']}</div>{sm}</div>
<div class="progress"><div class="bar">{bar}</div><span>{dn} of {len(names)} done{", %d in work"%fl if fl else ""}</span>{extra}</div></summary>
<div class="body"><p class="def"><strong>Goal:</strong> {inline(w['goal'])}</p><p class="def"><strong>Done when:</strong> {inline(w['done'])}</p>
<ol class="steps">{HEAD}{"".join(row(a,b) for a,b in w['steps'])}{ex}</ol></div></details>'''
def isactive(w): return any(status(x)=='flight' for x in [y[0] for y in w['steps']]+w['extra'])
act=[w for w in WS if isactive(w)]; idle=[w for w in WS if not isactive(w)]
def work(n):
    w=placed.get(n); sg=stg[n]
    tg=[t for t,c in (('step',any(n==x[0] for k in WS for x in k['steps'])),('entry',n in entries),('change',n in openc or bool(ref(n))),('branch',n in branches),('open PR',n in opr),('merged PR',n in merged)) if c]
    fam=sg.split(':')[0]; p={'plan':'<i class="on"></i><i></i><i></i>','build':'<i class="past"></i><i class="on"></i><i></i>','ship':'<i class="past"></i><i class="past"></i><i class="on"></i>'}[fam]
    wl=f'<div class="ws"><a href="#{w}">{w}</a></div>' if w else '<div class="ws none">no workstream</div>'
    return f'<div class="work"><div><div class="name">{e(n)}</div><div class="tags">{"".join(f"<span class=tag>{t}</span>" for t in tg)}</div></div><div><div class="pipe">{p}</div><div class="stage">{e(sg)}</div></div><div class="ago">{ago(n)}</div>{wl}</div>'
none.sort(key=lambda n:(status(n)!='flight',entries.get(n,{}).get('pri')=='parked',-last.get(n,0)))
idles=f'''<details class="group"><summary><span class="chev" aria-hidden="true">▶</span><div><div class="name">{len(idle)} workstreams</div><div class="sub">Nothing in work right now</div></div><span></span></summary><div class="body"><div class="groups">{"".join(wshtml(w) for w in idle)}</div></div></details>'''
page=head+'</style>\n'+f'''<main><header><h1>{e(title)}</h1><div class="meta">Written 2026-11-01, from <span class="stage">origin/main {sha}</span>. Forge read in full ({len(prs)} pull requests). Built in {tme:.0f}s.</div></header>
<div class="mock">Prototype run on this project's real data. No summary field exists yet, so none are shown.{f" {warn} step lines could not be read." if warn else ""}</div>
<section aria-labelledby="h-work"><h2 id="h-work">In work ({len(flight)})</h2><div class="list"><div class="work workhead" aria-hidden="true"><span>Task</span><span>Stage</span><span>Last commit</span><span>Workstream</span></div>{"".join(work(n) for n in flight)}</div></section>
<section aria-labelledby="h-ws"><h2 id="h-ws">Active workstreams ({len(act)})</h2><div class="groups">{"".join(wshtml(w) for w in act)}</div>
<div class="legend" aria-label="Status key"><span class="st done">done</span><span class="st flight">in flight</span><span class="st">recorded</span><span class="st planned">planned</span></div></section>
<section aria-labelledby="h-idle"><h2 id="h-idle">Other workstreams ({len(idle)})</h2>{idles}</section>
<section aria-labelledby="h-none"><h2 id="h-none">Not in a workstream</h2><details class="group"><summary><span class="chev" aria-hidden="true">▶</span><div><div class="name">{len(none)} tasks</div></div><span></span></summary><div class="body"><ul class="steps">{HEAD}{"".join(row(x) for x in none)}</ul></div></details></section></main>'''
h,b=page.split('</style>\n',1)
open(D+f'/site/{sys.argv[4]}.html','w',encoding='utf8').write('<!doctype html>\n<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">\n<style>body{margin:0}</style>\n'+h+'</style></head><body>\n'+b+'</body></html>\n')
print('time',round(tme,1),'ws',len(WS),'active',len(act),[w['n'] for w in act],'flight',len(flight),'none',len(none),'warn',warn,'entries',len(entries),'prs',len(prs))
for n in flight: print(' ',n,'|',stg[n],'|',placed.get(n))
