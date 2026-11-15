import NXOpen, NXOpen.CAE, traceback
LOG=r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\probe_log.txt"
out=open(LOG,"w")
def p(*a):
    out.write(" ".join(str(x) for x in a)+"\n"); out.flush()
D=lambda o:[a for a in dir(o) if not a.startswith('_') and 'ttribute' not in a]
s=NXOpen.Session.GetSession()
CFG=open(r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\cfg.txt").read().split("|")
SIM=CFG[8]; NEWSOL=CFG[9]
try:
    fem=s.Parts.BaseWork
    gb=[b for b in fem.Bodies if b.Name=="GROUND"][0]
    p("gb",gb.JournalIdentifier,D(gb))
    faces=list(gb.GetFaces()) if hasattr(gb,'GetFaces') else []
    p("faces",[f.JournalIdentifier for f in faces])
    sim=[pt for pt in s.Parts if pt.FullPath.lower()==SIM.lower()][0]
    s.Parts.SetActiveDisplay(sim, NXOpen.DisplayPartOption.AllowAdditional, NXOpen.PartDisplayPartWorkPartOption.UseLast)
    root=sim.ComponentAssembly.RootComponent
    p("root",root, [c.JournalIdentifier for c in root.GetChildren()] if root else None)
    comp=root.GetChildren()[0] if root and root.GetChildren() else None
    occ=[]
    for f in faces:
        try: occ.append(comp.FindOccurrence(f) if comp else sim.FindObject("CAE_Body(2)|"+f.JournalIdentifier))
        except Exception as e: p("occ err",f.JournalIdentifier,e)
    p("occ",[o.JournalIdentifier for o in occ if o])
    simo=sim.Simulation
    sol=list(simo.Solutions)[0]
    if sol.Name!=NEWSOL: sol.Rename(NEWSOL,False) if hasattr(sol,'Rename') else sol.SetName(NEWSOL)
    simo.ActiveSolution=sol
    p("sol",sol.Name)
    names=[c.Name for c in simo.Constraints]
    if "Fixed_Ground" not in names:
        bb=simo.CreateBcBuilderForConstraintDescriptor("fixedConstraint","Fixed_Ground",1)
        p("bcb",D(bb))
        tl=bb.TargetSelection if hasattr(bb,'TargetSelection') else None
        p("target",D(tl) if tl else None)
        sb=tl.SelectionList if hasattr(tl,'SelectionList') else None
        for o in occ:
            r=tl.SelectObjectList.Add(o) if hasattr(tl,'SelectObjectList') else sb.Add(o)
        bc=bb.CommitAddBc() if hasattr(bb,'CommitAddBc') else bb.Commit()
        bb.Destroy()
        p("bc",bc.Name if hasattr(bc,'Name') else bc)
    p("constraints",[c.Name for c in simo.Constraints], "in sol",[b.Name for b in sol.GetBcs()] if hasattr(sol,'GetBcs') else '')
    sim.Save(NXOpen.BasePart.SaveComponents.TrueValue, NXOpen.BasePart.CloseAfterSave.FalseValue)
    p("saved sim")
except Exception:
    p(traceback.format_exc())
out.close()
