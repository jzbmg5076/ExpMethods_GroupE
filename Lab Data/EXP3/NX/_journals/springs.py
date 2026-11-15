import NXOpen, NXOpen.CAE, traceback
LOG=r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\probe_log.txt"
PAIRS=r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\pairs.txt"
out=open(LOG,"w")
def p(*a):
    out.write(" ".join(str(x) for x in a)+"\n"); out.flush()
s=NXOpen.Session.GetSession()
try:
    fem=s.Parts.BaseWork; fm=fem.BaseFEModel; nm=fm.FenodeLabelMap
    pairs=[tuple(map(int,l.split(','))) for l in open(PAIRS).read().split()]
    colls=[m for m in fm.MeshManager.GetMeshCollectors() if m.CollectorType=="Celas1 Collector"]
    p("existing celas collectors",[c.Name for c in colls])
    if colls: coll=colls[0]
    else: coll=None
    existing=set()
    for c in colls:
        for m in c.GetMeshes(): existing.add(m.Name)
    p("existing meshes",existing)
    done=len(existing)
    for i,(g,t) in enumerate(pairs):
        if i<done: continue
        cb=fm.CaeConnections.CreateConnectionBuilder(NXOpen.CAE.CAEConnection.Null)
        cb.Type=NXOpen.CAE.CAEConnectionBuilder.ConnectionTypeEnum.NodeToNode
        cb.ElementType.ElementTypeName="CELAS1"
        if coll is not None:
            cb.ElementType.DestinationCollector.AutomaticMode=False
            cb.ElementType.DestinationCollector.ElementContainer=coll
        cb.SourceNodesSelection.Add(nm.GetNode(g)); cb.TargetNodesSelection.Add(nm.GetNode(t))
        m=cb.Commit(); cb.Destroy()
        if coll is None: coll=[c for c in fm.MeshManager.GetMeshCollectors() if c.CollectorType=='Celas1 Collector'][0]
        p("made",g,t,m.JournalIdentifier)
    coll.SetName("Corner_Springs") if coll.Name!="Corner_Springs" else None
    # set DOF Z on every spring mesh, rename
    meshes=list(coll.GetMeshes())
    for k,m in enumerate(meshes):
        pt=m.ElementPropertyTable
        pt.SetIntegerPropertyValue("translation dof, end a",3)
        pt.SetIntegerPropertyValue("translation dof, end b",3)
        p("mesh",m.Name,pt.GetIntegerPropertyValue("translation dof, end a"),pt.GetIntegerPropertyValue("translation dof, end b"))
    # stiffness
    pel=coll.ElementPropertyTable.GetNamedPropertyTablePropertyValue("Scalar Spring Property")
    ppt=pel.PropertyTable
    try:
        cur=ppt.GetScalarWithDataPropertyValue("translation spring stiffness")
        p("cur k", cur, [a for a in dir(cur) if not a.startswith('_')][:60])
    except Exception as e: p("get k err",e)
    unit=None
    for nmu in ["LbfPerInch","lbf/in","PoundForcePerInch","LbfPerIn"]:
        try:
            unit=fem.UnitCollection.FindObject(nmu); p("unit found",nmu); break
        except Exception as e: p("unit miss",nmu)
    if unit is None:
        try:
            ut=[u for u in fem.UnitCollection.GetMeasureTypeUnits("Stiffness")]
            p("stiff units",[(u.Name,u.Abbreviation) for u in ut])
        except Exception as e: p("measure err",e)
    ppt.SetBaseScalarWithDataPropertyValue("translation spring stiffness","323",unit)
    ppt.SetBaseScalarWithDataPropertyValue("rotation spring stiffness","0",NXOpen.Unit.Null)
    pel.SetName("PELAS_Corner_323")
    p("k set", pel.Name)
    fem.Save(NXOpen.BasePart.SaveComponents.TrueValue, NXOpen.BasePart.CloseAfterSave.FalseValue)
    p("saved")
except Exception:
    p(traceback.format_exc())
out.close()
