# LISP routines for AutoCAD and GstarCAD

Small AutoLISP commands for everyday drafting: extend and close polylines,
and find or hide layers inside XREFs.

## Download

| Download | Command | What it does |
|---|---|---|
| [⬇ AddVertex.lsp](https://github.com/TomaszDzieduszynski/lisp-routines/releases/latest/download/AddVertex.lsp) | `ADDVERTEX` | Adds a vertex at either end of a polyline or line. |
| [⬇ CLS.lsp](https://github.com/TomaszDzieduszynski/lisp-routines/releases/latest/download/CLS.lsp) | `CLS` | Closes the polylines and splines you select. |
| [⬇ CLP.lsp](https://github.com/TomaszDzieduszynski/lisp-routines/releases/latest/download/CLP.lsp) | `CLP` | Draws a polyline that closes itself automatically. |
| [⬇ DLAY.lsp](https://github.com/TomaszDzieduszynski/lisp-routines/releases/latest/download/DLAY.lsp) | `DLAY` | Substitute for `LAYOFF`, mainly for GstarCAD: hides the layer of each object you click, also inside XREFs. |
| [⬇ IDENT.lsp](https://github.com/TomaszDzieduszynski/lisp-routines/releases/latest/download/IDENT.lsp) | `IDENT` | Shows the layer of each object you click, also inside XREFs. |

**[⬇ All five in one file (lisp-routines.zip)](https://github.com/TomaszDzieduszynski/lisp-routines/releases/latest/download/lisp-routines.zip)**

Release 1.0.0 · AutoCAD and GstarCAD · free and open source

## Install

1. Download the `.lsp` files you want and keep them in one folder, e.g.
   `Documents\CAD\lisp`.
2. In AutoCAD or GstarCAD type `APPLOAD`, pick the file and click
   **Load**. Or drag the `.lsp` file onto the open drawing.
3. Type the command name (e.g. `CLS`) and press Enter.

**Load them every time automatically:** in `APPLOAD`, open the **Startup
Suite** (**Contents...**), click **Add** and pick the files.

**Security warning when loading?** AutoCAD asks before loading files from
folders it does not trust. Click **Load Once**, or add the folder to
*Options > Files > Trusted Locations* to stop the question.

## Commands

**ADDVERTEX** - Click a polyline or line (or select it first), then click a
point: a vertex is added at the nearer end. Run it again to keep extending
the same polyline.\
*May work inconsistently across AutoCAD and GstarCAD versions.*

**CLS** - Click a polyline or spline, or click empty space to window
several. Locked layers are skipped and reported.

**CLP** - Draw a polyline as usual; it is closed when you press Enter.

**DLAY** - Click objects to hide their layers; Enter to finish. On a layout
the layer is frozen in the current viewport, in model space it is turned
off. Made because `LAYOFF` misbehaves in GstarCAD viewports; in AutoCAD use
`LAYOFF`.

**IDENT** - Click objects to print their layer names; Enter to finish.

## Good to know

- **AutoCAD LT:** LT 2024 and newer can run LISP, but these routines are
  not tested there.
- **Different CAD versions** handle some commands slightly differently. If
  something behaves oddly, press Ctrl+Z.

## License and credits

<img src="images/bzqp_logo.png" width="40" align="middle" alt="bzqp"> Tomasz "bzqp" Dzieduszyński, 2025–2026. Written by hand, Claude Opus 5.5 used for styling before publication.

Free software under the [GNU General Public License v3 or later](LICENSE):
you may use it for any work, including paid work, and share or change it, as
long as what you share stays under the same license.

What changed in each version: [CHANGELOG.md](CHANGELOG.md). How to publish a
new version: [docs/RELEASING.md](docs/RELEASING.md).

AutoCAD is a trademark of Autodesk, Inc. GstarCAD is a trademark of
Gstarsoft Co., Ltd. This project is not affiliated with either company.
