# Breadboard project box with two hinged lids

Files
- project_box.scad: parametric source. Use `part = "closed" | "open" | "base" | "lid1" | "lid2" | "print_layout"`
- project_box_closed.stl: closed assembly (3 separate shells, lids lifted by 0.1 mm)
- project_box_base.stl, project_box_lid1.stl, project_box_lid2.stl: print-ready, already oriented
- project_box_print_layout.stl: all three parts laid out
- previews/*.png: closed, open, print layout, hinge cross-sections

Render: `openscad -o out.stl -D 'part="base"' project_box.scad`

Assembly: hinge pins are 1.75 mm filament, about 120 mm each. Push one through each hinge
and melt or flatten the ends slightly. For an M3 rod, set pin_d = 3.3.
