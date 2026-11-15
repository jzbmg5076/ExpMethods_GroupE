import NXOpen, NXOpen.CAE, traceback
LOG=r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\probe_log.txt"
out=open(LOG,"w")
def p(*a):
    out.write(" ".join(str(x) for x in a)+"\n"); out.flush()
D=lambda o:[a for a in dir(o) if not a.startswith('_') and 'ttribute' not in a]
s=NXOpen.Session.GetSession()
try:
    sim=s.Parts.BaseWork
    p("work",sim.FullPath)
    fem=sim.FemPart
    gid=[b for b in fem.Bodies if b.Name=="GROUND"][0].JournalIdentifier
    comp=sim.ComponentAssembly.RootComponent.GetChildren()[0]
    occ=[]
    for n in range(1,400):
        try:
            o=comp.FindObject("PROTO#%s|CAE_Face(%d)"%(gid,n)); occ.append(o)
        except Exception: pass
    p("faces",gid,[o.JournalIdentifier for o in occ])
    simo=sim.Simulation
    bc=[c for c in simo.Constraints if c.Name=="Fixed_Ground"][0]
    bb=simo.CreateBcBuilderForBc(bc)
    tsm=bb.TargetSetManager
    p("tsm",D(tsm))
    objs=[]
    for o in occ:
        t=NXOpen.CAE.SetObject(); t.Obj=o; t.SubType=NXOpen.CAE.CaeSetObjectSubType.NotSet; t.SubId=0; objs.append(t)
    tsm.SetTargetSetMembers(0, NXOpen.CAE.CaeSetGroupFilterType.GeomFace, objs)
    bb.CommitBc(); bb.Destroy()
    p("bc updated")
    sim.Save(NXOpen.BasePart.SaveComponents.TrueValue, NXOpen.BasePart.CloseAfterSave.FalseValue)
    p("saved sim")
except Exception:
    p(traceback.format_exc())
out.close()
