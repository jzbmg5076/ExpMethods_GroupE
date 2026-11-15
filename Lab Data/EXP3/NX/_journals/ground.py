import NXOpen, NXOpen.CAE, NXOpen.Features, NXOpen.GeometricUtilities, traceback, sys
LOG=r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\probe_log.txt"
out=open(LOG,"w")
def p(*a):
    out.write(" ".join(str(x) for x in a)+"\n"); out.flush()
s=NXOpen.Session.GetSession()
CFG=open(r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\cfg.txt").read().split("|")
IP=CFG[0]; ox,oy,oz,L,W,H=CFG[1:7]
try:
    ip=None
    for pt in s.Parts:
        if pt.FullPath.lower()==IP.lower(): ip=pt
    if ip is None:
        ip,st=s.Parts.OpenActiveDisplay(IP, NXOpen.DisplayPartOption.AllowAdditional)
    else:
        s.Parts.SetActiveDisplay(ip, NXOpen.DisplayPartOption.AllowAdditional, NXOpen.PartDisplayPartWorkPartOption.UseLast)
    p("ip",ip.FullPath, "bodies",[b.JournalIdentifier for b in ip.Bodies])
    if any(f.Name=="GROUND_BLOCK" for f in ip.Features):
        p("ground exists already")
    else:
        bb=ip.Features.CreateBlockFeatureBuilder(NXOpen.Features.Feature.Null)
        bb.Type=NXOpen.Features.BlockFeatureBuilder.Types.OriginAndEdgeLengths
        bb.BooleanOption.Type=NXOpen.GeometricUtilities.BooleanOperation.BooleanType.Create
        bb.SetOriginAndLengths(NXOpen.Point3d(float(ox),float(oy),float(oz)),L,W,H)
        f=bb.Commit(); bb.Destroy()
        f.SetName("GROUND_BLOCK")
        b=f.GetBodies()[0]; b.SetName("GROUND")
        p("created",f.JournalIdentifier,b.JournalIdentifier)
    ip.Save(NXOpen.BasePart.SaveComponents.TrueValue, NXOpen.BasePart.CloseAfterSave.FalseValue)
    p("saved ip", [ (b.JournalIdentifier,b.Name) for b in ip.Bodies])
except Exception:
    p(traceback.format_exc())
out.close()
