# Envy Media Server Case

A 3D-printable, single-box enclosure that turns a bare HP ENVY x360 m6-aq103dx mainboard (i5-7200U) into a small media server. The board sits on the lower floor with its stock cooler; a removable 4-bay drive shelf above holds 3.5" and 2.5" drives on USB-to-SATA adapters, fed through an internal powered USB hub and one 12 V supply.

**Live page:** https://duhbinci.github.io/envy-media-server-case/ (interactive 3D view with full build, printed-shell-only and parts-only modes, cost, parts, display notes, storage research and downloads)

## Files

| Path | What it is |
| --- | --- |
| `case/stl/shell.stl` | Box shell, 250 × 160 × 141 mm. Prints upright, no supports. |
| `case/stl/shelf.stl` | Removable drive shelf, 243 × 153 mm. |
| `case/stl/lid.stl` | Vented lid, flipped flat side down for printing. |
| `case/envy_media_server_case.3mf` | All three parts in one slicer project file. |
| `case/envy_media_server_case_print_files.zip` | STLs, 3MF and OpenSCAD source in one zip. |
| `laptop_case.scad` | OpenSCAD source for all three parts. |
| `case/parts_list.md` | What to buy (Daraz Nepal links). |
| `case/cost_estimate.md` | Cost estimate in NPR. |
| `storage/storage_expansion.md` | Research behind the drive shelf. |
| `validation/case_validation.md` | Review of the original design, plus BIOS display options. |
| `index.html`, `viewer/` | The GitHub Pages site and the models it loads. |

## Before you print

Values marked `[MEASURE]` in `laptop_case.scad` (board outline, screw holes, port positions, hub size) are estimates. Measure your board and parts with calipers, update the file, and re-export the STLs from OpenSCAD.

## Run

Use a local static server: `python3 -m http.server 8000`, then visit `http://localhost:8000`. To publish, enable GitHub Pages on `main` branch, `/ (root)` folder in **Settings → Pages**.
