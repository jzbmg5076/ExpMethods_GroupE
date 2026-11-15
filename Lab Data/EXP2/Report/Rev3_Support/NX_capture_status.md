# Authentic NX screenshot status

No usable screenshots from the final AI_SIM_TAKE_2 models were located in the supplied files. The images in `Report/Rev2_MATLAB/figures/fig03_NX_*` are MATLAB re-renderings and must not be presented as NX screenshots. The final NX report PDFs embed comparison curves, not NX viewport captures.

NX 2512 is installed at `C:/Program Files/Siemens/DesigncenterNX2512`. Both supported journal invocations (`run_journal -nx` and `run_journal -simcenter3d`) fail before opening any file: `failed to initialize UFUN 949804`. The configured license server is `29000@currents.ad.uc.edu`; a read-only DNS/connection probe fails with `getaddrinfo 11001`. No source part, FEM, SIM, or solver result was modified.

To obtain the required authentic images once NX can access its license:

1. Open `Lab Data/EXP2/NX/AI_SIM_TAKE_2/copper.prt` or `Copper_hollow.prt` and capture the NX model viewport. The tube end should show its hollow geometry.
2. Open each final `.sim` file, load its saved Solution 1 `.op2`, and display the steady-state nodal temperature contour. Retain the NX color legend, units, material/file identifier, and hot/cold ends in the image.
3. Use NX's image export or screenshot command to save PNG files. These are model images, so the user specifically requires their origin to be NX.
4. Ensure the displayed result corresponds to the final face-only-heating `AI_SIM_TAKE_2` solution, rather than the older simulation folders.

`capture_nx.py` is a prepared read-only NX journal for a first geometry image export. It was not executed successfully because initialization failed. It does not save or change the model. Its output requires visual verification before inclusion in a deck.

`existing_decks_contact.png` and `report_embedded.png` are investigation previews only, not assets approved for the presentation.
