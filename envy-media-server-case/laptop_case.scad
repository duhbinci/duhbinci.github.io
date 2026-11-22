// ============================================================
// Media server enclosure: HP ENVY x360 m6-aq103dx (15-aq1xx) mainboard
// ONE box, two floors:
//   lower floor  - mainboard + IO daughterboard + stock cooler
//   upper floor  - removable drive shelf with up to 4 x 3.5" HDDs on
//                  USB-to-SATA adapters, a powered USB 3 hub and a 92 mm fan
// A short USB cable leaves the board's right USB-A port and comes straight
// back in through a slot just above it, into the hub.
// Print: shell, drive shelf, lid (3 parts)
// ============================================================
// [MEASURE] = estimate until checked with calipers.
// [VERIFY]  = from a standard or spec sheet; check it on your parts.
// Render: set `part`, then F6 -> export STL.
//   "shell" | "shelf" | "lid" -> print as-is (lid already flipped)
//   "assembly" -> preview only (ghost components shown)
// The assembly also echoes "COMP|..." lines that feed the 3D viewer.
// Assembly order: board into the shell, drives screwed to the shelf,
// shelf dropped onto the ledges, cables, lid (its ribs clamp the drives).
// ============================================================

part        = "assembly";  // "shell" | "shelf" | "lid" | "assembly"
show_parts  = true;        // ghost components in assembly view
board_dxf   = "";          // optional board outline DXF (mm, origin = board bottom-left)
use_inserts = false;       // true = holes sized for heat-set inserts
bed_x = 256; bed_y = 256;  // your printer bed, for the fit check

// ---------- Board [MEASURE] ----------
// X = along the laptop's width (left-side ports at X=0, right-side ports at X=max)
// Y = front (palm rest) to back (hinge), Z = up.
board_l   = 240;     // board length (X)  [MEASURE]
board_w   = 110;     // board depth  (Y)  [MEASURE]
board_t   = 1.2;     // PCB thickness
clearance = 2;       // gap between board edge and inner wall

under_h   = 6;       // solder-side clearance (standoff height)
over_h    = 22;      // clearance above board top (cooler stack is ~10 mm) [MEASURE]

// Mainboard holes: [x, y] from board bottom-left corner [MEASURE]
// HP holds this board with 7 screws (5x M2x4, 2x M2x2.5) in irregular spots.
holes = [
  [8, 8], [118, 6], [232, 8],
  [6, 100], [96, 104], [232, 102],
  [176, 54]
];

// ---------- IO daughterboard (left-side USB-A + audio) [MEASURE] ----------
io_pos   = [-1, 12];     // bottom-left corner, board coords
io_size  = [24, 60, 1.0];
io_holes = [[6, 6], [6, 54]];

// ---------- Stock cooler [MEASURE] ----------
fan_pos   = [150, 30];   // blower fan corner, board coords
fan_size  = [62, 60, 8];
fin_pos   = [196, 96];   // fin stack against the back wall
fin_size  = [40, 14, 8];

// ---------- Shell ----------
wall      = 3;
floor_t   = 3;
lid_t     = 3;
corner_r  = 4;
standoff_d = 7;
pad_d      = standoff_d + 6;   // solid floor pad under each standoff (vents skip it)
board_pilot_d = use_inserts ? 3.2 : 1.7;   // M2 self-tap / M2 heat-set insert
screw_d    = 3.2;              // M3 clearance
pilot_d    = use_inserts ? 4.0 : 2.6;      // M3 pilot
boss_d     = 10;               // lid screw bosses in the 4 inside corners

// ---------- Ports [MEASURE offsets] ----------
// [wall, offset along wall from board origin, width, height, z above board top, shape]
// Layout per HP service guide: left = USB-A + audio (IO board),
// right = DC jack, HDMI, USB-C, USB-A, card reader. Front = power button.
// "round": width = diameter, height ignored.
ports = [
  ["left",  20, 14.5, 7,  0.5, "rect"],    // USB-A (IO board)
  ["left",  48, 7,    7,  1.5, "round"],   // audio combo
  ["right", 8,  11,   11, 1,   "round"],   // DC jack (pigtail, panel mount)
  ["right", 26, 16,   7,  0,   "rect"],    // HDMI
  ["right", 48, 10,   4.5, 0.5, "rect"],   // USB-C
  ["right", 64, 14.5, 7,  0,   "rect"],    // USB-A -> loop cable to the drive hub
  ["right", 84, 25,   4,  0,   "rect"],    // SD card reader
  ["front", 30, 12,   12, 4,   "round"]    // 12 mm panel momentary power button
];
port_names = ["USB-A (left)", "Audio jack", "19.5 V charger jack", "HDMI out", "USB-C",
              "USB-A (right)", "SD card slot", "Power button"];
loop_port = 5;           // index in ports[] of the USB-A the drive loop uses

// Cooler exhaust grille in the back wall, lined up with the fin stack
exhaust = [fin_pos[0] - 2, fin_size[0] + 4, 10];   // [x offset, width, height]

// ---------- Drive shelf [VERIFY drive dims] ----------
// Drives stand on their long edge, running along X: fan end on the left,
// SATA connectors and adapters on the right.
n_bays   = 4;           // slots built into the shelf
n_drives = 2;           // drives fitted now (viewer only)
hdd_l = 147;  hdd_w = 101.6;  hdd_t = 26.1;   // SFF-8301 3.5" drive
hdd_side_x = [28.5, 130.1];  // side holes, from the non-connector end [VERIFY]
hdd_side_z = 6.35;           // side holes, from the drive's base face [VERIFY]
hdd_screw_d = 3.8;      // #6-32 clearance
grommet_d   = 8.5;      // counterbore under the shelf for rubber grommets
// 2.5" drives (SFF-8201) fit the same bays on edge, connector end lined up with
// the 3.5" connector end so the same adapters reach. M3 side holes. [VERIFY]
ssd_l = 100;  ssd_w = 69.85;  ssd_t = 9.5;     // 7 to 15 mm thick all fit a bay
ssd_side_x = [14, 90.6];     // side holes, from the non-connector end
ssd_side_z = 3.0;            // side holes, from the drive's base face
ssd_screw_d = 3.4;           // M3 clearance
n_ssd = 1;                   // 2.5" drives fitted now (viewer only, in the bays after the 3.5" ones)
drive_gap = 10;         // air gap between drives
fan_gap   = 26;         // room for a 25 mm thick intake fan inside the left wall
cable_gap = 60;         // USB-SATA adapter + plug + cable bend, per drive
shelf_t   = 3;
ledge_w   = 4;          // ledge the shelf rests on, all round
dc12_d    = 11;         // DC-022 5.5 x 2.1 mm panel jack (usually an 11 mm hole) [VERIFY]
intake_fan  = 80;       // 12 V intake fan in the left wall, upper floor (80 or 92)
exhaust_fan = 60;       // 12 V exhaust fan inside the back wall, upper floor, above the adapters

// Powered 4-port USB 3 hub (a plain cased one) in a cradle on the inside of the
// right wall: it sits on a ledge between two end stops and two zip ties go
// round it, through the strap bridges. [MEASURE your hub]
hub_size  = [100, 30, 13];       // length (Y) x height (Z) x thickness (X)
hub_y     = 26;                  // from the inner front wall
hub_z     = 48;                  // above the shelf top (bottom of the hub)
strap_w   = 6;                   // zip-tie width the bridges take

usb_slot = [15, 10];             // re-entry slot [width along Y, height]

// ---------- Ventilation ----------
vent_slot_w = 3;
vent_pitch  = 7;
vent_margin = 18;

// ---------- Derived ----------
bay_w  = n_bays*hdd_t + (n_bays + 1)*drive_gap;      // shelf depth needed (Y)
in_l   = max(board_l + 2*clearance, fan_gap + hdd_l + cable_gap);
in_w   = max(board_w + 2*clearance, bay_w);
low_h  = under_h + board_t + over_h;                 // lower floor height
shelf_z = floor_t + low_h;                           // shelf underside
shelf_top = shelf_z + shelf_t;
top_gap = 4;                                         // above the drives, lid ribs live here
in_h   = low_h + shelf_t + 0.5 + hdd_w + top_gap;
out_l  = in_l + 2*wall;
out_w  = in_w + 2*wall;
out_h  = in_h + floor_t;

bx = wall + clearance;                               // board origin: right up to the back wall
by = out_w - wall - clearance - board_w;
board_top = floor_t + under_h + board_t;

drive_x0 = wall + fan_gap;                           // fan (non-connector) end of the drives
drive_y  = function(i) wall + drive_gap + i*(hdd_t + drive_gap);
drive_z0 = shelf_top + 0.5;

function fan_pitch(f) = f == 40 ? 32 : f == 60 ? 50 : f == 80 ? 71.5 : f == 92 ? 82.5 : 105;
cage_fan = intake_fan;
fan_pitch = fan_pitch(intake_fan);
hub_x = out_l - wall - 3 - hub_size[2];    // hub face against the strap bridges (3 mm off the wall)
fan_cz = drive_z0 + hdd_w/2;

boss_c = [for (x = [wall + boss_d/2 - 1, out_l - wall - boss_d/2 + 1],
               y = [wall + boss_d/2 - 1, out_w - wall - boss_d/2 + 1]) [x, y]];
notch  = boss_d + 3;     // square cut from each shelf corner, clears the boss gussets

lp = ports[loop_port];
ex_x = drive_x0 + hdd_l + 1 + exhaust_fan/2;           // exhaust fan centre, just past the drive ends
ex_z = shelf_top + hdd_w - exhaust_fan/2 - 2;          // high up, clear of the adapters below
usb_slot_y = by + lp[1] + lp[2]/2 - usb_slot[0]/2;   // straight above the loop port
usb_slot_z = shelf_top + 14;
dc12_y = out_w - wall - 22;
dc12_z = shelf_top + 22;

$fn = 48;

// ---------- Sanity checks ----------
assert(lp[0] == "right", "Loop port must be on the right wall");
assert(usb_slot_y > wall + boss_d + 1, "USB slot collides with the front corner boss");
assert(usb_slot_z + usb_slot[1] < shelf_top + hub_z - 4 || usb_slot_y > wall + hub_y + hub_size[0] + 4,
       "USB slot sits behind the hub");
assert(dc12_z + dc12_d/2 < shelf_top + hub_z - 4 || dc12_y - dc12_d/2 > wall + hub_y + hub_size[0] + 4,
       "12 V jack sits behind the hub");
assert(shelf_top + hub_z + hub_size[1] < out_h - 4, "Hub too tall for the upper floor");
assert(hub_y + hub_size[0] + 3 < in_w, "Hub too long for the box depth");
assert(intake_fan <= min(in_w, hdd_w) - 2, "Intake fan too big for the upper floor");
assert(ex_x + exhaust_fan/2 < out_l - wall - boss_d + 0.5, "Exhaust fan hits the back-right corner boss");
assert(wall + hub_y + hub_size[0] + 3 < out_w - wall - 25, "Hub cradle hits the exhaust fan");
assert(ex_z - exhaust_fan/2 > drive_z0 + 8 + 14 + 2, "Exhaust fan sits on top of the adapters");

// fit check: no outside ears, so the footprint is the box itself
_fit = (out_l <= bed_x && out_w <= bed_y) || (out_w <= bed_x && out_l <= bed_y);
echo(str("Box: ", out_l, " x ", out_w, " x ", out_h, " mm, ", n_bays, " bays, ", cage_fan, " mm fan"));
echo(str("FIT|Shell|", out_l, "|", out_w, "|", _fit ? "ok" : "too big"));
echo(str("FIT|Shelf|", in_l - 1, "|", in_w - 1, "|", _fit ? "ok" : "too big"));
echo(str("FIT|Lid|", out_l, "|", out_w, "|", _fit ? "ok" : "too big"));
if (!_fit) echo(str("WARNING: the box is larger than the ", bed_x, " x ", bed_y, " bed"));

// ---------- Component list for the viewer (assembly coordinates) ----------
// COMP|id|label|x|y|z|sx|sy|sz|kind|group|note
module comp(id, label, p, s, kind, group, note) {
  echo(str("COMP|", id, "|", label, "|", p[0], "|", p[1], "|", p[2], "|",
           s[0], "|", s[1], "|", s[2], "|", kind, "|", group, "|", note));
}
module list_components() {
  comp("board", "Mainboard", [bx, by, floor_t + under_h], [board_l, board_w, board_t], "pcb", "case",
       "i5-7200U board on 7 M2 standoffs on the lower floor, pushed against the back wall. Outline and holes are estimates until measured.");
  comp("io", "IO daughterboard", [bx + io_pos[0], by + io_pos[1], floor_t + under_h],
       io_size, "pcb", "case", "Left-side USB-A and audio jack, flat cable to the mainboard.");
  comp("fan", "Stock blower fan", [bx + fan_pos[0], by + fan_pos[1], board_top], fan_size, "fan", "case",
       "Stock cooler fan, blows into the fin stack at the back wall.");
  comp("fins", "Cooler fin stack", [bx + fin_pos[0], by + fin_pos[1], board_top], fin_size, "metal", "case",
       "Exhausts through the grille in the back wall.");
  comp("pipe", "Heat pipe", [bx + fan_pos[0] - 40, by + 60, board_top], [40, 8, 3], "metal", "case",
       "Copper heat pipe from the CPU to the fin stack.");
  // port openings (viewer markers)
  for (i = [0 : len(ports) - 2]) {
    p = ports[i]; pw = p[2]; ph = p[5] == "round" ? p[2] : p[3]; z = board_top + p[4];
    if (p[0] == "left")  comp(str("port", i), port_names[i], [-0.5, by + p[1], z], [6, pw, ph], "port", "case",
                              str(port_names[i], " opening in the left wall, ", pw, " x ", ph, " mm."));
    if (p[0] == "right") comp(str("port", i), port_names[i], [out_l - 5.5, by + p[1], z], [6, pw, ph], "port", "case",
                              str(port_names[i], " opening in the right wall, ", pw, " x ", ph, " mm.",
                                  i == 3 ? " Plug your monitor in here. It works once Windows or Linux has started; the BIOS screen may only show on the laptop's internal display connector." : ""));
  }
  comp("dcjack", "DC jack (19.5 V)", [out_l - wall - 14, by + 8 - 1.5, board_top - 1], [14, 14, 14], "metal", "case",
       "Laptop charger input on its pigtail, panel-mounted in the right wall.");
  comp("button", "Power button", [bx + 30, wall - 1, board_top + 4 - 6], [12, 20, 12], "metal", "case",
       "12 mm momentary switch in the front wall, wired to the board's power-button pads.");
  for (i = [0 : n_drives - 1]) {
    comp(str("hdd", i + 1), str("3.5\" HDD ", i + 1),
         [drive_x0, drive_y(i), drive_z0], [hdd_l, hdd_t, hdd_w], "drive", "shelf",
         "147 x 101.6 x 26.1 mm, on edge. 2 screws up through grommets in the shelf, clamped at the top by the lid ribs.");
    comp(str("adp", i + 1), str("USB-SATA adapter ", i + 1),
         [drive_x0 + hdd_l, drive_y(i) + 3, drive_z0 + 8], [48, 20, 14], "pcb", "shelf",
         "Adapter with 12 V input, plugged into the drive's SATA connector. Needs the 60 mm gap.");
  }
  for (i = [n_drives : n_drives + n_ssd - 1]) {
    comp(str("ssd", i + 1), str("2.5\" drive (bay ", i + 1, ")"),
         [drive_x0 + hdd_l - ssd_l, drive_y(i), drive_z0], [ssd_l, ssd_t, ssd_w], "drive", "shelf",
         "100 x 69.85 x 7-15 mm, on edge in a normal bay, 2 M3 screws up through the shelf. USB powered, no 12 V needed.");
    comp(str("adp", i + 1), str("USB-SATA cable ", i + 1),
         [drive_x0 + hdd_l, drive_y(i) + 1, drive_z0 + 6], [40, 14, 10], "pcb", "shelf",
         "Plain bus-powered USB 3 to SATA cable for the 2.5\" drive.");
  }
  for (i = [n_drives + n_ssd : n_bays - 1])
    comp(str("bay", i + 1), str("Empty bay ", i + 1),
         [drive_x0, drive_y(i), drive_z0], [hdd_l, hdd_t, hdd_w], "empty", "shelf",
         "Room for another 3.5\" drive later.");
  comp("hub", "Powered USB 3 hub",
       [hub_x, wall + hub_y, shelf_top + hub_z], [hub_size[2], hub_size[0], hub_size[1]], "pcb", "case",
       "Cased 4-port hub in a cradle on the right wall: ledge, end stops and two zip ties. Its own cable goes out the slot to the board's USB-A port.");
  comp("cagefan", str(intake_fan, " mm intake fan"),
       [wall + 1, wall + (in_w - intake_fan)/2, fan_cz - intake_fan/2], [25, intake_fan, intake_fan], "fan", "case",
       "12 V fan in the left wall of the upper floor, pulls air in across the drives.");
  comp("exfan", str(exhaust_fan, " mm exhaust fan"),
       [ex_x - exhaust_fan/2, out_w - wall - 25, ex_z - exhaust_fan/2], [exhaust_fan, 25, exhaust_fan], "fan", "case",
       "12 V fan screwed to the inside of the back wall, high up above the drive adapters. Pushes warm air out the back.");
  comp("dc12", "12 V input jack", [out_l - wall - 12, dc12_y - 6, dc12_z - 6], [14, 12, 12], "metal", "case",
       "5.5 x 2.1 mm panel jack for the 12 V 5 A brick. Inside, a 1-to-4 splitter feeds the 3.5\" adapters, both fans and the hub's 5 V converter.");
  comp("buck", "12 V to 5 V converter", [out_l - wall - 22, wall + hub_y + 10, shelf_top + hub_z + hub_size[1] + 4], [18, 40, 10], "pcb", "case",
       "Small buck board that powers the hub from the same 12 V brick. Sits on top of the hub cradle, stuck down with foam tape.");
  // USB loop: right USB-A port -> slot straight above it
  echo(str("LOOP|", out_l, "|", by + lp[1] + lp[2]/2, "|", board_top + lp[4] + lp[3]/2,
           "|", out_l, "|", usb_slot_y + usb_slot[0]/2, "|", usb_slot_z + usb_slot[1]/2));
  echo(str("DIMS|", out_l, "|", out_w, "|", out_h, "|", shelf_z));
}

// ---------- Helpers ----------
module rrect(l, w, h, r) {
  hull() for (x = [r, l-r], y = [r, w-r])
    translate([x, y, 0]) cylinder(r = r, h = h);
}
module vent_slots(l, w, h, m = vent_margin) {
  for (x = [m : vent_pitch : l - m - vent_slot_w])
    translate([x, m, 0]) cube([vent_slot_w, w - 2*m, h]);
}
// vertical slots in a wall facing Y (front/back), from x0 to x1
module wall_slots_y(x0, x1, y, z, h) {
  for (x = [x0 : 6 : x1 - 3]) translate([x, y, z]) cube([3, wall + 2, h]);
}

module port_cut(p) {
  w = p[0]; off = p[1]; pw = p[2]; ph = p[3]; pz = p[4]; round_ = p[5] == "round";
  z = board_top + pz;
  module c(t) {
    if (round_) translate([0, pw/2, pw/2]) rotate([0, 90, 0]) cylinder(d = pw, h = t);
    else cube([t, pw, ph]);
  }
  if (w == "left")       translate([-1, by + off, z]) c(wall + 2);
  else if (w == "right") translate([out_l - wall - 1, by + off, z]) c(wall + 2);
  else if (w == "front") translate([bx + off + pw, -1, z]) rotate([0, 0, 90]) c(wall + 2);
  else if (w == "back")  translate([bx + off + pw, out_w - wall - 1, z]) rotate([0, 0, 90]) c(wall + 2);
}

function std_holes() = concat(holes, [for (q = io_holes) [io_pos[0] + q[0], io_pos[1] + q[1]]]);

// ---------- Shell ----------
module shell() {
  difference() {
    union() {
      difference() {
        rrect(out_l, out_w, out_h, corner_r);
        translate([wall, wall, floor_t]) rrect(in_l, in_w, out_h, corner_r - 1);
        translate([0, 0, -1]) vent_slots(out_l, out_w, floor_t + 2);
      }
      // pads + standoffs for mainboard and IO board, added after the vents
      for (h = std_holes()) translate([bx + h[0], by + h[1], 0]) {
        cylinder(d = pad_d, h = floor_t);
        translate([0, 0, floor_t - 0.01]) cylinder(d = standoff_d, h = under_h + 0.01);
      }
      // ledge all round for the drive shelf, 45-degree underside so it prints without supports
      difference() {
        translate([wall - 0.01, wall - 0.01, shelf_z - ledge_w]) cube([in_l + 0.02, in_w + 0.02, ledge_w]);
        hull() {
          translate([wall, wall, shelf_z - ledge_w - 0.01]) cube([in_l, in_w, 0.01]);
          translate([wall + ledge_w, wall + ledge_w, shelf_z]) cube([in_l - 2*ledge_w, in_w - 2*ledge_w, 0.01]);
        }
        translate([wall + ledge_w, wall + ledge_w, shelf_z - 1]) cube([in_l - 2*ledge_w, in_w - 2*ledge_w, 2]);
      }
      // lid screw bosses in the 4 corners of the upper floor, each on a gusset into the corner
      for (c = boss_c) hull() {
        translate([c[0], c[1], shelf_top]) cylinder(d = boss_d, h = out_h - shelf_top);
        translate([c[0] < out_l/2 ? wall : out_l - wall, c[1] < out_w/2 ? wall : out_w - wall,
                   shelf_top - boss_d - 2]) cylinder(d = 1, h = 0.1);
      }
    }
    for (h = std_holes())
      translate([bx + h[0], by + h[1], 1]) cylinder(d = board_pilot_d, h = floor_t + under_h);
    for (p = ports) port_cut(p);
    for (c = boss_c) translate([c[0], c[1], out_h - 14]) cylinder(d = pilot_d, h = 15);
    // lower floor: cooler exhaust grille (back) and intake slots (front)
    wall_slots_y(bx + exhaust[0], bx + exhaust[0] + exhaust[1], out_w - wall - 1, board_top, exhaust[2]);
    wall_slots_y(bx + 60, bx + 200, -1, board_top, 12);
    // upper floor: intake fan in the left wall
    translate([-1, wall + in_w/2, fan_cz]) rotate([0, 90, 0]) {
      cylinder(d = cage_fan - 4, h = wall + 2);
      for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*fan_pitch/2, sy*fan_pitch/2, 0]) cylinder(d = 3.4, h = wall + 2);
    }
    // upper floor: exhaust slots in the front wall, exhaust fan in the back wall
    wall_slots_y(drive_x0 + hdd_l + 4, out_l - wall - boss_d - 2, -1, shelf_top + 10, hdd_w - 20);
    translate([ex_x, out_w + 1, ex_z]) rotate([90, 0, 0]) {
      cylinder(d = exhaust_fan - 3, h = wall + 2);
      for (sx = [-1, 1], sz = [-1, 1])
        translate([sx*fan_pitch(exhaust_fan)/2, sz*fan_pitch(exhaust_fan)/2, 0]) cylinder(d = 3.4, h = wall + 2);
    }
    // USB re-entry slot (rounded), right wall, straight above the loop port
    translate([out_l - wall - 1, usb_slot_y, usb_slot_z])
      hull() for (y = [2, usb_slot[0] - 2], z = [2, usb_slot[1] - 2])
        translate([0, y, z]) rotate([0, 90, 0]) cylinder(r = 2, h = wall + 2);
    // 12 V input jack, right wall
    translate([out_l - wall - 1, dc12_y, dc12_z]) rotate([0, 90, 0]) cylinder(d = dc12_d, h = wall + 2);
  }
  // hub cradle (ledge, end stops, strap bridges) and the cable zip-tie point, inside the right wall
  hz = shelf_top + hub_z; hy = wall + hub_y; hl = hub_size[0]; hh = hub_size[1]; ht = hub_size[2];
  ri = out_l - wall;   // inner face of the right wall
  // ledge under the hub, 45-degree underside so it prints without supports
  hull() {
    translate([ri - ht - 5, hy - 3, hz - 3]) cube([ht + 5 + 0.01, hl + 6, 3]);
    translate([ri - 0.5, hy - 3, hz - ht - 8]) cube([0.51, hl + 6, 0.1]);
  }
  // end stops
  for (y = [hy - 3, hy + hl]) translate([ri - ht - 5, y, hz - 0.01]) cube([ht + 5 + 0.01, 3, 14]);
  // strap bridges: bars 3 mm off the wall, the zip tie threads behind them
  for (y = [hy + hl*0.25, hy + hl*0.75]) translate([ri - 3 - 0.01, y - strap_w/2 - 3, hz + 2]) difference() {
    cube([3.01, strap_w + 6, hh - 4]);
    translate([-1, 3, 3]) cube([2.5, strap_w, hh - 10]);
  }
  // zip-tie point for the hub cable, beside the re-entry slot
  difference() {
    translate([ri - 8 + 0.01, usb_slot_y - 10, usb_slot_z - 6]) cube([8, 6, usb_slot[1] + 12]);
    translate([ri - 5.5, usb_slot_y - 11, usb_slot_z - 3]) cube([3, 8, usb_slot[1] + 6]);
  }
}

// ---------- Drive shelf (assembly position: underside at shelf_z) ----------
module shelf() {
  sl = in_l - 1; sw = in_w - 1;
  translate([wall + 0.5, wall + 0.5, 0]) difference() {
    union() {
      cube([sl, sw, shelf_t]);
      // ribs between drive slots keep each drive upright
      for (i = [0 : n_bays])
        translate([drive_x0 - wall - 0.5, drive_y(i) - drive_gap + 1 - wall - 0.5, shelf_t - 0.01])
          cube([hdd_l, drive_gap - 2, 6]);
    }
    // corner notches for the boss gussets
    for (x = [0, sl - notch], y = [0, sw - notch]) translate([x - 0.01, y - 0.01, -1]) cube([notch + 0.02, notch + 0.02, shelf_t + 2]);
    // drive screw slots (+-3 mm) with grommet counterbores from below
    for (i = [0 : n_bays - 1], sx = hdd_side_x)
      translate([drive_x0 + sx - wall - 0.5, drive_y(i) + hdd_side_z - wall - 0.5, 0]) {
        hull() for (d = [-3, 3]) translate([d, 0, -1]) cylinder(d = hdd_screw_d, h = shelf_t + 2);
        hull() for (d = [-3, 3]) translate([d, 0, -1]) cylinder(d = grommet_d, h = 2.5);
      }
    // 2.5" drive screw slots (+-2 mm), same bays
    for (i = [0 : n_bays - 1], sx = ssd_side_x)
      translate([drive_x0 + hdd_l - ssd_l + sx - wall - 0.5, drive_y(i) + ssd_side_z - wall - 0.5, 0])
        hull() for (d = [-2, 2]) translate([d, 0, -1]) cylinder(d = ssd_screw_d, h = shelf_t + 2);
    // airflow slots through the shelf in the adapter zone (lets warm air from the board rise out)
    for (y = [12 : 8 : sw - 16])
      translate([drive_x0 + hdd_l + 6 - wall, y, -1]) cube([cable_gap - 14, 3, shelf_t + 2]);
  }
}

// ---------- Lid (assembly orientation, lip and ribs pointing down) ----------
module lid() {
  rib_h = top_gap + 4;    // reaches 4 mm down between the drive tops
  difference() {
    union() {
      rrect(out_l, out_w, lid_t, corner_r);
      translate([wall + 0.4, wall + 0.4, -2])
        difference() {
          rrect(in_l - 0.8, in_w - 0.8, 2, corner_r - 1);
          translate([2, 2, -1]) rrect(in_l - 4.8, in_w - 4.8, 4, corner_r - 2);
        }
      for (i = [0 : n_bays])
        translate([drive_x0 + 10, drive_y(i) - drive_gap + 1.5, -rib_h]) cube([hdd_l - 20, drive_gap - 3, rib_h]);
    }
    // clear the corner bosses through the lip
    for (c = boss_c) translate([c[0], c[1], -5]) cylinder(d = boss_d + 1, h = 5);
    for (c = boss_c) translate([c[0], c[1], -1]) {
      cylinder(d = screw_d, h = lid_t + 2);
      translate([0, 0, lid_t + 1 - 1.6]) cylinder(d1 = screw_d, d2 = 6.5, h = 1.61);
    }
    translate([0, 0, -3]) vent_slots(out_l, out_w, lid_t + 4);
  }
}

// ---------- Output ----------
if (part == "shell") shell();
else if (part == "shelf") shelf();
else if (part == "lid") translate([0, out_w, lid_t]) rotate([180, 0, 0]) lid();
else if (part == "lid_asm") lid();                       // viewer export, unflipped
else {
  list_components();
  shell();
  translate([0, 0, shelf_z]) shelf();
  translate([0, 0, out_h + 30]) lid();
  if (show_parts) {
    %translate([bx, by, floor_t + under_h])
      if (board_dxf != "") linear_extrude(board_t) import(board_dxf);
      else cube([board_l, board_w, board_t]);
    for (i = [0 : n_drives - 1])
      %translate([drive_x0, drive_y(i), drive_z0]) cube([hdd_l, hdd_t, hdd_w]);
  }
}
