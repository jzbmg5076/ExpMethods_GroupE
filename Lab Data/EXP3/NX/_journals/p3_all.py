import NXOpen, NXOpen.CAE, NXOpen.Features, NXOpen.GeometricUtilities, traceback
LOG=r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\probe_log.txt"
out=open(LOG,"w")
def p(*a):
    out.write(" ".join(str(x) for x in a)+"\n"); out.flush()
s=NXOpen.Session.GetSession()
DIR=r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\P3_CutoutFrame_Springs"
SIM=DIR+r"\Experiment3_Model3_sim1.sim"; FEM=DIR+r"\Experiment3_Model3_fem1.fem"; IP=DIR+r"\Experiment3_Model3_fem1_i.prt"
G=(0.0,0.0,-1.25,"23.84","12","0.25")
PLATE=[2,3,29,27]
SAVE=lambda pt: pt.Save(NXOpen.BasePart.SaveComponents.TrueValue, NXOpen.BasePart.CloseAfterSave.FalseValue)
def find(path):
    for pt in s.Parts:
        if pt.FullPath.lower()==path.lower(): return pt
def show(pt): s.Parts.SetActiveDisplay(pt, NXOpen.DisplayPartOption.AllowAdditional, NXOpen.PartDisplayPartWorkPartOption.UseLast)
try:
    sim=find(SIM)
    if sim is None: sim,st=s.Parts.OpenActiveDisplay(SIM, NXOpen.DisplayPartOption.AllowAdditional)
    else: show(sim)
    fem=sim.FemPart; p("fem",fem.FullPath, "assoc", fem.FullPathForAssociatedCadPart)
    assert fem.FullPath.lower()==FEM.lower() and fem.FullPathForAssociatedCadPart.lower()==IP.lower()
    # 1 ground block in idealized part
    ip=find(IP)
    if ip is None: ip,st=s.Parts.OpenActiveDisplay(IP, NXOpen.DisplayPartOption.AllowAdditional)
    else: show(ip)
    if not any(f.Name=="GROUND_BLOCK" for f in ip.Features):
        bb=ip.Features.CreateBlockFeatureBuilder(NXOpen.Features.Feature.Null)
        bb.Type=NXOpen.Features.BlockFeatureBuilder.Types.OriginAndEdgeLengths
        bb.BooleanOption.Type=NXOpen.GeometricUtilities.BooleanOperation.BooleanType.Create
        bb.SetOriginAndLengths(NXOpen.Point3d(G[0],G[1],G[2]),G[3],G[4],G[5])
        f=bb.Commit(); bb.Destroy(); f.SetName("GROUND_BLOCK"); f.GetBodies()[0].SetName("GROUND")
    SAVE(ip); p("ground block ok")
    # 2 FEM: update, mesh ground
    show(fem); fm=fem.BaseFEModel
    if len(list(fem.Bodies))<2: fm.UpdateFemodel()
    gb=[b for b in fem.Bodies if b.Name=="GROUND"][0]
    p("bodies",[(b.JournalIdentifier,b.Name) for b in fem.Bodies])
    if not [m for m in fm.MeshManager.GetMeshCollectors() if m.Name=="Ground_Solid"]:
        mat=list(fem.MaterialManager.PhysicalMaterials)[0]; p("mat",mat.Name)
        ppt=fem.PhysicalPropertyTables.CreatePhysicalPropertyTable("PSOLID","NX NASTRAN - Structural","NX NASTRAN","PSOLID2",2)
        ppt.PropertyTable.SetMaterialPropertyValue("material",False,mat)
        cb=fm.MeshManager.CreateCollectorBuilder(NXOpen.CAE.MeshCollector.Null,"Solid")
        cb.CollectorName="Ground_Solid"; cb.PropertyTable.SetNamedPropertyTablePropertyValue("Solid Property",ppt)
        mc=cb.Commit(); cb.Destroy()
        mb=fm.MeshManager.CreateMesh3dTetBuilder(NXOpen.CAE.Mesh3d.Null)
        mb.ElementType.ElementTypeName="CTETRA(10)"
        mb.ElementType.DestinationCollector.ElementContainer=mc
        mb.ElementType.DestinationCollector.AutomaticMode=False
        mb.SelectionList.Add(gb)
        mb.PropertyTable.SetBaseScalarWithDataPropertyValue("quad mesh overall edge size","0.25",fem.UnitCollection.FindObject("Inch"))
        mb.CommitMesh(); mb.Destroy()
    SAVE(fem); p("ground mesh ok")
    # 3 node lookup
    nm=fm.FenodeLabelMap
    T=[]
    for lab in PLATE:
        c=nm.GetNode(lab).Coordinates; T.append((c.X,c.Y,-1.0)); p("plate node",lab,c.X,c.Y,c.Z)
    best=[(1e9,None,None)]*4; lab=0
    while True:
        lab=nm.AskNextNodeLabel(lab)
        if lab<=0: break
        c=nm.GetNode(lab).Coordinates
        for i,t in enumerate(T):
            d=(c.X-t[0])**2+(c.Y-t[1])**2+(c.Z-t[2])**2
            if d<best[i][0]: best[i]=(d,lab,(c.X,c.Y,c.Z))
    for b in best: p("ground node",b)
    pairs=[(b[1],pl) for b,pl in zip(best,PLATE)]
    # 4 springs
    colls=[m for m in fm.MeshManager.GetMeshCollectors() if m.CollectorType=="Celas1 Collector"]
    coll=colls[0] if colls else None
    done=sum(len(list(c.GetMeshes())) for c in colls)
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
        if coll is None: coll=[c for c in fm.MeshManager.GetMeshCollectors() if c.CollectorType=="Celas1 Collector"][0]
        p("spring",g,"->",t,m.JournalIdentifier)
    if coll.Name!="Corner_Springs": coll.SetName("Corner_Springs")
    for m in coll.GetMeshes():
        pt=m.ElementPropertyTable
        pt.SetIntegerPropertyValue("translation dof, end a",3); pt.SetIntegerPropertyValue("translation dof, end b",3)
    pel=coll.ElementPropertyTable.GetNamedPropertyTablePropertyValue("Scalar Spring Property")
    pel.PropertyTable.SetBaseScalarWithDataPropertyValue("translation spring stiffness","323",fem.UnitCollection.FindObject("lbf/in"))
    pel.PropertyTable.SetBaseScalarWithDataPropertyValue("rotation spring stiffness","0",NXOpen.Unit.Null)
    pel.SetName("PELAS_Corner_323")
    SAVE(fem); p("springs ok")
    # 5 sim: rename solution, fixed ground
    show(sim); simo=sim.Simulation
    sol=list(simo.Solutions)[0]
    if sol.Name!="CornerSprings_Modal": sol.Rename("CornerSprings_Modal",False)
    simo.ActiveSolution=sol
    gid=gb.JournalIdentifier
    comp=sim.ComponentAssembly.RootComponent.GetChildren()[0]
    occ=[]
    for n in range(1,600):
        try: occ.append(comp.FindObject("PROTO#%s|CAE_Face(%d)"%(gid,n)))
        except Exception: pass
    p("ground faces",len(occ))
    if "Fixed_Ground" not in [c.Name for c in simo.Constraints]:
        bb=simo.CreateBcBuilderForConstraintDescriptor("fixedConstraint","Fixed_Ground",1)
    else:
        bb=simo.CreateBcBuilderForBc([c for c in simo.Constraints if c.Name=="Fixed_Ground"][0])
    objs=[]
    for o in occ:
        t=NXOpen.CAE.SetObject(); t.Obj=o; t.SubType=NXOpen.CAE.CaeSetObjectSubType.NotSet; t.SubId=0; objs.append(t)
    bb.TargetSetManager.SetTargetSetMembers(0, NXOpen.CAE.CaeSetGroupFilterType.GeomFace, objs)
    if "Fixed_Ground" not in [c.Name for c in simo.Constraints]: bb.CommitAddBc()
    else: bb.CommitBc()
    bb.Destroy()
    p("bcs in sol",[b.Name for b in sol.GetBcs()])
    SAVE(sim)
    # 6 solve
    mgr=NXOpen.CAE.SimSolveManager.GetSimSolveManager(s)
    r=mgr.SolveChainOfSolutions([sol], NXOpen.CAE.SimSolution.SolveOption.Solve, NXOpen.CAE.SimSolution.SetupCheckOption.CompleteCheckAndOutputErrors, NXOpen.CAE.SimSolution.SolveMode.Foreground)
    p("solve",r); SAVE(sim); p("done")
except Exception:
    p(traceback.format_exc())
out.close()
