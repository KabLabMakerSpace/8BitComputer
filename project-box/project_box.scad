// =====================================================================
//  Breadboard project box with two hinged lids  (OpenSCAD, parametric)
//  - Base: open-top box (room for an Arduino/wiring under the breadboard)
//  - Lid 1 (inner): hinges on the BACK long side; its inside face holds
//    a solderless breadboard in a snug recessed pocket.
//  - Lid 2 (outer): hinges on the FRONT long side and folds over lid 1;
//    its inside face holds a 3x5 index card (project notes).
//  - Hinges: knuckle hinges with a through-hole for a 1.75 mm filament pin
//    (each part prints separately, then a piece of filament is pushed
//    through the knuckles as the hinge pin).
//
//  Coordinates: X = length (left/right), Y = depth (front y=0 / back y=W),
//  Z = up. Base occupies [0,L] x [0,W] x [0,H].
//
//  Render examples:
//    openscad -o project_box_closed.stl -D 'part="closed"' project_box.scad
//    openscad -o base.stl -D 'part="base"' project_box.scad
// =====================================================================

/* [Part selector] */
// "closed", "open", "base", "lid1", "lid2", "print_layout"
part = "closed";

/* [Breadboard pocket (lid 1)] */
bb_len    = 83;     // breadboard length (X).  Half-size = 83, full-size ~165
bb_wid    = 54;     // breadboard width  (Y).  Half-size = 54, full-size ~55
bb_clear  = 0.4;    // total clearance added to each pocket dimension (0.2/side)
bb_pocket_depth = 4.5;   // pocket depth (breadboard body is ~8.5-10 mm tall)
bb_height = 10;     // breadboard body height incl. adhesive (for clearance check)
finger_notch_d = 16;     // finger notches at the pocket's long edges

/* [Index card recess (lid 2)] */
card_len   = 127;   // 3x5 card length (X)
card_wid   = 76;    // 3x5 card width  (Y)
card_clear = 0.4;   // total clearance per dimension
card_depth = 1.0;   // recess depth
card_tabs  = true;  // corner retaining tabs (card tucks under them)
tab_leg    = 8;     // corner tab leg length
tab_thick  = 0.6;   // tab thickness (leaves card_depth - tab_thick slot)
thumb_notch_d = 20; // thumb notch to lift the card out
thumb_notch_depth = 1.8;  // deeper than recess, < lid2 thickness

/* [Box] */
L     = 140;        // outer length  (X)  - must exceed card_len + 2*wall
W     = 90;         // outer depth   (Y)  - must exceed card_wid + 2*wall
H     = 35;         // base height   (Z)
wall  = 2.5;        // wall thickness
floor_t = 2.0;      // base floor thickness
corner_r = 3;       // outer corner rounding (vertical edges)

/* [Lids] */
t1 = 6;             // lid 1 thickness (pocket depth + 1.5 mm floor)
t2 = 3;             // lid 2 thickness (card recess + 2 mm floor)
rim_h = 2;          // lid 1 locating rim that drops inside the base walls
rim_w = 1.2;
rim_clear = 0.3;    // gap between rim and base inner wall
lid2_lip = 8;       // lid 2 overhangs the back hinge by this much (grip)

/* [Hinges] */
kr        = 3;      // knuckle outer radius (knuckle dia = 6 mm)
pin_d     = 2.1;    // pin hole for 1.75 mm filament (use 3.3 for an M3 pin)
k_clear   = 0.4;    // axial gap between neighbouring knuckles
r_clear   = 0.5;    // radial gap lid-plate <-> base knuckle / lid <-> column
n_knuckle = 7;      // odd: base knuckles at both ends, lid knuckles between
hinge_margin = 10;  // hinge starts this far in from each end

/* [Misc] */
cable_notch = true; // USB / cable notch in the right end wall
cable_w = 14; cable_h = 9;
lift_notch_r = 6;   // finger notch in base front wall to pry lid 1 up
open1 = 110;        // opening angle of lid 1 for part="open"
open2 = 125;        // opening angle of lid 2 for part="open"

$fn = 48;
eps = 0.01;

// ---------------- derived ----------------
hinge_len = L - 2*hinge_margin;
seg = hinge_len / n_knuckle;
// lid 1 hinge axis (back): just outside the back wall, flush with lid 1 top
a1y = W + kr;          a1z = H + t1 - kr;
// lid 2 hinge axis (front): outside the front wall, flush with lid 2 top
a2y = -(kr + r_clear); a2z = H + t1 + t2 - kr;

assert(card_len + card_clear + 2*wall < L, "L too small for the card");
assert(card_wid + card_clear + 2*wall < W, "W too small for the card");
assert(H - floor_t > bb_height - bb_pocket_depth + 5, "base too shallow for breadboard");

// ---------------- helpers ----------------
// extrude a 2D profile drawn in the (Y,Z) plane along X
module xprism(x0, len) translate([x0,0,0]) rotate([90,0,90]) linear_extrude(len) children();

// x-start of knuckle i (i = 0..n_knuckle-1), length seg - k_clear
function kx(i) = hinge_margin + i*seg + k_clear/2;
klen = seg - k_clear;
function is_base_k(i) = (i % 2 == 0);

module rbox(sz, r) {   // box with rounded vertical edges
    hull() for (x=[r, sz[0]-r], y=[r, sz[1]-r]) translate([x,y,0]) cylinder(r=r, h=sz[2]);
}

module pin_hole(ay, az) {
    translate([-1, ay, az]) rotate([0,90,0]) cylinder(d=pin_d, h=L+2, $fn=24);
}

// ---------------- BASE ----------------
module base_knuckles() {
    for (i=[0:n_knuckle-1]) if (is_base_k(i)) {
        // back hinge (lid 1): column on the outside of the back wall
        xprism(kx(i), klen) hull() {
            translate([a1y, a1z]) circle(r=kr);
            translate([W, H-6]) square([2*kr, a1z-(H-6)]);
            translate([W, H-6-2*kr]) square([eps, 1]);   // 45-deg chamfer, no overhang
        }
        // front hinge (lid 2): column outside the front wall, rises past lid 1
        xprism(kx(i), klen) hull() {
            translate([a2y, a2z]) circle(r=kr);
            translate([a2y-kr, H-6]) square([2*kr, a2z-(H-6)]);
            translate([-eps, H-6-2*kr-r_clear]) square([eps, 1]);
        }
        // bridge between front column and the front wall (below lid 1)
        xprism(kx(i), klen) translate([a2y, H-6]) square([-a2y+eps, 6]);
    }
}

module base() {
    difference() {
        union() {
            difference() {
                rbox([L, W, H], corner_r);
                translate([wall, wall, floor_t]) rbox([L-2*wall, W-2*wall, H], max(corner_r-wall, 0.5));
            }
            base_knuckles();
        }
        pin_hole(a1y, a1z);
        pin_hole(a2y, a2z);
        // finger notch in the front wall to lift lid 1 (sits in a lid-knuckle slot)
        translate([L/2, -1, H]) rotate([-90,0,0]) cylinder(r=lift_notch_r, h=wall+2);
        // cable / USB notch in the right end wall
        if (cable_notch)
            translate([L-wall-1, W/2-cable_w/2, floor_t+4]) cube([wall+2, cable_w, cable_h]);
    }
}

// ---------------- LID 1 (breadboard) ----------------
module lid1() {
    pw = bb_len + bb_clear;  pd = bb_wid + bb_clear;
    difference() {
        union() {
            // plate (stops r_clear short of the back hinge)
            translate([0,0,H]) intersection() {
                rbox([L, W, t1], corner_r);
                cube([L, W - r_clear, t1]);
            }
            // locating rim that drops inside the base walls
            translate([wall+rim_clear, wall+rim_clear, H-rim_h])
            difference() {
                cube([L-2*(wall+rim_clear), W-2*(wall+rim_clear), rim_h+eps]);
                translate([rim_w, rim_w, -1])
                    cube([L-2*(wall+rim_clear+rim_w), W-2*(wall+rim_clear+rim_w), rim_h+2]);
            }
            // knuckles
            for (i=[0:n_knuckle-1]) if (!is_base_k(i))
                xprism(kx(i), klen) hull() {
                    translate([a1y, a1z]) circle(r=kr);
                    translate([W-3, H]) square([3-r_clear, t1]);
                }
        }
        pin_hole(a1y, a1z);
        // clearance for the base knuckles (radial gap)
        for (i=[0:n_knuckle-1]) if (is_base_k(i))
            translate([kx(i)-k_clear/2, a1y, a1z]) rotate([0,90,0])
                cylinder(r=kr+r_clear, h=seg);
        // breadboard pocket in the inside (bottom) face
        translate([L/2-pw/2, W/2-pd/2, H-rim_h-1]) cube([pw, pd, rim_h+1+bb_pocket_depth]);
        // finger notches at the middle of both long pocket edges
        for (s=[-1,1]) translate([L/2, W/2 + s*pd/2, H-rim_h-1])
            cylinder(d=finger_notch_d, h=rim_h+1+bb_pocket_depth);
    }
}

// ---------------- LID 2 (index card) ----------------
module lid2() {
    cw = card_len + card_clear;  cd = card_wid + card_clear;
    z0 = H + t1;                         // inside face of lid 2
    cx = L/2 - cw/2;  cy = W/2 - cd/2;
    difference() {
        union() {
            translate([0, 0, z0]) rbox([L, W + lid2_lip, t2], corner_r);
            for (i=[0:n_knuckle-1]) if (!is_base_k(i))
                xprism(kx(i), klen) hull() {
                    translate([a2y, a2z]) circle(r=kr);
                    translate([a2y, z0]) square([-a2y + eps, t2]);  // stays in front of y=0
                }
        }
        pin_hole(a2y, a2z);
        // clearance for the front base knuckle columns
        for (i=[0:n_knuckle-1]) if (is_base_k(i))
            translate([kx(i)-k_clear/2, a2y, a2z]) rotate([0,90,0])
                cylinder(r=kr+r_clear, h=seg);
        // card recess (open toward lid 1)
        translate([cx, cy, z0-1]) cube([cw, cd, card_depth+1]);
        // thumb notch on the back long edge of the recess
        translate([L/2, cy+cd, z0-1]) cylinder(d=thumb_notch_d, h=thumb_notch_depth+1);
    }
    // corner retaining tabs at the mouth of the recess (card slides under)
    if (card_tabs)
        for (c=[[cx,cy,0],[cx+cw,cy,90],[cx+cw,cy+cd,180],[cx,cy+cd,270]])
            translate([c[0], c[1], z0]) rotate([0,0,c[2]])
                linear_extrude(tab_thick) polygon([[0,0],[tab_leg,0],[0,tab_leg]]);
}

// ---------------- assemblies ----------------
module rot_about_x(ay, az, ang) {
    translate([0, ay, az]) rotate([ang,0,0]) translate([0,-ay,-az]) children();
}

// assembly_gap lifts each lid a hair so the closed STL is three clean,
// separate manifold shells instead of solids fused at the seating faces.
assembly_gap = 0.1;
module closed() {
    base();
    translate([0,0,assembly_gap]) lid1();
    translate([0,0,2*assembly_gap]) lid2();
}

module open_view() {
    color("SteelBlue") base();
    color("Orange")   rot_about_x(a1y, a1z, -open1) lid1();  // swings back
    color("LightGreen") rot_about_x(a2y, a2z, open2) lid2();  // swings forward
}

// Print orientation: base upright; both lids flipped so the flat OUTER face
// is on the bed and the pockets face up. Knuckles are flush with that face.
module lid1_print() translate([0, 0, H + t1]) mirror([0,0,1]) lid1();
module lid2_print() translate([0, 0, H + t1 + t2]) mirror([0,0,1]) lid2();

module print_layout() {
    base();
    translate([0, W + 20, 0]) lid1_print();
    translate([0, 2*W + 40 + lid2_lip, 0]) lid2_print();
}

if (part == "closed")        closed();
else if (part == "open")     open_view();
else if (part == "base")     base();
else if (part == "lid1")     lid1_print();
else if (part == "lid2")     lid2_print();
else if (part == "print_layout") print_layout();
