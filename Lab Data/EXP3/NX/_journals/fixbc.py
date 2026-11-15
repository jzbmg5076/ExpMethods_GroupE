import NXOpen, NXOpen.CAE, traceback
LOG=r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\probe_log.txt"
out=open(LOG,"w")
def p(*a):
    out.write(" ".join(str(x) for x in a)+"\n"); out.flush()
s=NXOpen.Session.GetSession()
SIM=r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\P3_CutoutFrame_Springs\Experiment3_Model3_sim1.sim"
try:
    sim=[pt for pt in s.Parts if pt.FullPath.lower()==SIM.lower()][0]
    s.Parts.SetActiveDisplay(sim, NXOpen.DisplayPartOption.AllowAdditional, NXOpen.PartDisplayPartWorkPartOption.UseLast)
    simo=sim.Simulation
    p("solutions",[x.Name for x in simo.Solutions],"constraints",[c.Name for c in simo.Constraints])
    sol=[x for x in simo.Solutions if x.Name=="CornerSprings_Modal"][0]
    simo.ActiveSolution=sol
    bc=[c for c in simo.Constraints if c.Name=="Fixed_Ground"][0]
    if bc.Name not in [b.Name for b in sol.GetBcs()]:
        try: sol.AddBc(bc); p("added via sol.AddBc")
        except Exception as e:
            p("sol.AddBc err",e); simo.AddBc(bc); p("added via simo.AddBc")
    p("bcs in sol",[b.Name for b in sol.GetBcs()])
    sim.Save(NXOpen.BasePart.SaveComponents.TrueValue, NXOpen.BasePart.CloseAfterSave.FalseValue)
    mgr=NXOpen.CAE.SimSolveManager.GetSimSolveManager(s)
    r=mgr.SolveChainOfSolutions([sol], NXOpen.CAE.SimSolution.SolveOption.Solve, NXOpen.CAE.SimSolution.SetupCheckOption.CompleteCheckAndOutputErrors, NXOpen.CAE.SimSolution.SolveMode.Foreground)
    p("solve",r); sim.Save(NXOpen.BasePart.SaveComponents.TrueValue, NXOpen.BasePart.CloseAfterSave.FalseValue); p("done")
except Exception:
    p(traceback.format_exc())
out.close()
