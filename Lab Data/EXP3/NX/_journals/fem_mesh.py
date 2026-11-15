import NXOpen, NXOpen.CAE, traceback
LOG=r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\probe_log.txt"
out=open(LOG,"w")
def p(*a):
    out.write(" ".join(str(x) for x in a)+"\n"); out.flush()
D=lambda o:[a for a in dir(o) if not a.startswith('_') and 'ttribute' not in a]
s=NXOpen.Session.GetSession()
CFG=open(r"C:\path\to\ExpMethods_GroupE\Lab Data\EXP3\NX\_journals\cfg.txt").read().split("|")
FEM=CFG[7]
try:
    fem=None
    for pt in s.Parts:
        if pt.FullPath.lower()==FEM.lower(): fem=pt
    s.Parts.SetActiveDisplay(fem, NXOpen.DisplayPartOption.AllowAdditional, NXOpen.PartDisplayPartWorkPartOption.UseLast)
    fm=fem.BaseFEModel
    p("bodies before",[b.JournalIdentifier for b in fem.Bodies])
    bodies=list(fem.Bodies)
    p("bodies after",[(b.JournalIdentifier,b.Name) for b in bodies])
    if len(bodies)<2: raise Exception("ground body not in FEM")
    gb=[b for b in bodies if b.JournalIdentifier!="CAE_Body(1)"][0]
    # physical property PSOLID2 with plate material
    mat=list(fem.MaterialManager.PhysicalMaterials)[0]
    p("mat",mat.Name)
    mcs=[m for m in fm.MeshManager.GetMeshCollectors() if m.Name=="Ground_Solid"]
    if mcs: mc=mcs[0]
    else:
        ppt=fem.PhysicalPropertyTables.CreatePhysicalPropertyTable("PSOLID","NX NASTRAN - Structural","NX NASTRAN","PSOLID2",2)
        ppt.PropertyTable.SetMaterialPropertyValue("material",False,mat)
        p("ppt",ppt.Name)
        cb=fm.MeshManager.CreateCollectorBuilder(NXOpen.CAE.MeshCollector.Null,"Solid")
        cb.CollectorName="Ground_Solid"
        cb.PropertyTable.SetNamedPropertyTablePropertyValue("Solid Property",ppt)
        mc=cb.Commit(); cb.Destroy()
    p("collector",mc.JournalIdentifier)
    mb=fm.MeshManager.CreateMesh3dTetBuilder(NXOpen.CAE.Mesh3d.Null)
    p("tetbuilder",D(mb))
    mb.ElementType.ElementTypeName="CTETRA(10)"
    mb.ElementType.DestinationCollector.ElementContainer=mc
    mb.ElementType.DestinationCollector.AutomaticMode=False
    mb.SelectionList.Add(gb)
    u=fem.UnitCollection.FindObject("Inch")
    mb.PropertyTable.SetBaseScalarWithDataPropertyValue("quad mesh overall edge size","0.25",u)
    meshes=mb.CommitMesh(); mb.Destroy()
    p("meshes",[m.JournalIdentifier for m in meshes])
    p("numnodes",fm.FenodeLabelMap.NumNodes)
    fem.Save(NXOpen.BasePart.SaveComponents.TrueValue, NXOpen.BasePart.CloseAfterSave.FalseValue)
    p("saved")
except Exception:
    p(traceback.format_exc())
out.close()
