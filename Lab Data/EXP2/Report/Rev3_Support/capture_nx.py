import NXOpen
import os
base = r'C:\path\to\ExpMethods_GroupE'
out = os.path.join(base, r'Sandbox\ChatGPT\EXP2_Presentation_Build\nx_screenshots')
session = NXOpen.Session.GetSession()
with open(os.path.join(out, 'capture_log.txt'), 'w') as log:
    try:
        part, status = session.Parts.OpenBaseDisplay(os.path.join(base, r'Lab Data\EXP2\NX\AI_SIM_TAKE_2\copper.prt'))
        status.Dispose()
        log.write('opened ' + str(part.Name) + '\n')
        part.ModelingViews.WorkView.Fit()
        builder = part.Views.CreateImageExportBuilder()
        log.write(str(dir(builder)) + '\n')
        builder.FileName = os.path.join(out, 'copper_geometry.png')
        builder.FileFormat = NXOpen.Gateway.ImageExportBuilder.FileFormats.Png
        builder.Commit()
        builder.Destroy()
        log.write('export complete\n')
    except Exception as e:
        log.write(repr(e))
        raise
