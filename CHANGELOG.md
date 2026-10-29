# Changelog

Each routine has its own version, written at the top of its `.lsp` file.
A release bundles the current versions of all of them. Versions before the
first public release were used privately.

## 1.0.0 (first public release)

| Routine | Version |
|---|---|
| AddVertex | 1.3.0 (2026) |
| CLS | 1.1.0 (2026) |
| CLP | 1.1.0 (2026) |
| DLAY | 1.1.0 (2026) |
| IDENT | 1.0.0 (2025) |

# History of each routine

### AddVertex

**1.3.0 (2026)**
- Arc segments stay on the right segments when a vertex is added at the
  start of the polyline. Before, every arc moved one segment along.
- Reads and writes the polyline data directly instead of through ActiveX.

**1.2.0 (2026)**
- Lines are converted to a polyline automatically.
- Running `ADDVERTEX` again continues the same polyline without selecting
  it again.
- Uses only an active selection, not the previous one, which internal
  commands could overwrite.
- The polyline is correctly shown as selected after the command.

**1.1.0 (2025)**
- Fixed version of the first one: adds a vertex at the end of a polyline
  nearer to the picked point; uses the previously selected polyline if
  there is one.

**1.0.0 (2025)**
- First version, proof of concept, but buggy.

### CLS

**1.1.0 (2026)**
- Click a polyline to close it, or click empty space to start a selection
  window and close every polyline and spline inside it.
- Also closes old-style 2D and 3D polylines; skips meshes.
- Splines are closed with the `Closed2` property (falls back to
  `SPLINEDIT`) instead of being made periodic.
- Reports how many objects were closed, already closed, or could not be
  closed (e.g. on a locked layer). One Ctrl+Z undoes the whole command.

**1.0.0 (2025)**
- Closes one picked polyline or spline.

### CLP

**1.1.0 (2026)**
- Pressing Enter before drawing anything no longer closes a polyline drawn
  earlier.
- A polyline already closed with C while drawing is left as it is.

**1.0.0 (2025)**
- Draws a polyline and closes it when you finish.

### DLAY

**1.1.0 (2026)**
- Inside an XREF, hides the layer of the block you clicked (e.g. a door or
  a piece of furniture) instead of the layer of the line inside that block,
  which was often `0`.

**1.0.0 (2026)**
- Hides the layer of each clicked object, also inside XREFs: freezes it in
  the current viewport on a layout, turns it off in model space. A
  workaround for `LAYOFF` in GstarCAD layout viewports.

### IDENT

**1.0.0 (2025)**
- Shows the layer of each clicked object, also inside XREFs and blocks.
