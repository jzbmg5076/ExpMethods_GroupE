import NXOpen, NXOpen.CAE, traceback
LOG=r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\probe_log.txt"
out=open(LOG,"w")
def p(*a):
    out.write(" ".join(str(x) for x in a)+"\n"); out.flush()
s=NXOpen.Session.GetSession()
try:
    sim=s.Parts.BaseWork
    sol=sim.Simulation.ActiveSolution
    p("solving",sim.FullPath,sol.Name)
    mgr=NXOpen.CAE.SimSolveManager.GetSimSolveManager(s)
    r=mgr.SolveChainOfSolutions([sol], NXOpen.CAE.SimSolution.SolveOption.Solve, NXOpen.CAE.SimSolution.SetupCheckOption.CompleteCheckAndOutputErrors, NXOpen.CAE.SimSolution.SolveMode.Foreground)
    p("result",r)
    sim.Save(NXOpen.BasePart.SaveComponents.TrueValue, NXOpen.BasePart.CloseAfterSave.FalseValue)
    p("saved")
except Exception:
    p(traceback.format_exc())
out.close()
