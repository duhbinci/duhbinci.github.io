# Validation of laptop_case.scad (2026-10-19)

Source checked: `/mnt/project-files/laptop_case.scad` (the only existing work in the project; no earlier threads, uploads or repos).

## What the file actually is
A **bare-motherboard enclosure** (laptop mainboard repurposed as a mini PC). That matches your goal.

## Laptop specs (HP spec sheet you shared, HP ENVY x360 m6-aq103dx, W2K45UA)
- Size: 14.96 x 9.84 x 0.74 in = **380 x 250 x 18.8 mm**, 4.79 lb
- 15.6" FHD touch, i5-7200U, 12 GB DDR4, 1 TB HDD
- Ports: 1x USB-C 3.1, 2x USB-A 3.1, HDMI, headphone/mic combo, SD card reader
- Port sides per the HP m6-aq0xx/aq1xx service guide: **left** = USB-A + audio combo; **right** = DC power jack, HDMI, USB-C, USB-A, card reader

Note: the spec sheet calls it "m6-aq103dx"; the file comments call it "15-aq1xx". HP's service guide covers both names as the same platform, so the board info in the comments is consistent.

## Model checks (rendered with OpenSCAD, meshes checked with trimesh)
| Check | Result |
|---|---|
| Compiles, built-in asserts (ear/cavity clearance) | Pass |
| Base and lid meshes watertight, consistent winding | Pass |
| Outer box | 310 x 210 x 38.6 mm |
| Footprint incl. screw ears | **322 x 222 mm** |
| Lid lip fit | 0.4 mm/side clearance, fine for FDM |
| Lid print orientation | Already flipped flat-face-down; countersinks print as a ~46° cone, OK |
| Floor/lid vents vs standoff pads | Pads added back after vents, no undercut |
| Port cutouts | Inside wall height (z 10.6 to 17.6 mm), no collisions |

## Problems found
1. **Board size and all 5 mounting holes are placeholders** (300 x 200 mm, neat rectangle). The file itself says the real board uses 7 screws in irregular positions. Nothing can be called "validated" against the real board until these are measured. A 300 x 200 board is also implausibly large for a 15" laptop of 380 x 250 mm (inferred, not measured).
2. **Ports don't match the laptop's layout.** The file puts HDMI + 2 USB-A on the left and 2 ports on the right; the real layout is USB-A + audio on the left and HDMI, USB-C, USB-A, card reader and DC jack on the right. Offsets and sizes are also placeholders.
3. **No card reader slot and no defined DC jack location** (the jack is on a pigtail, so it needs its own panel-mount hole).
4. **Too big for most printers at the current placeholder size.** 322 x 222 mm won't fit Ender 3 (220x220), Prusa MK4 (250x210) or Bambu P1/X1 (256x256). This will likely resolve itself once the real (smaller) board size is entered; otherwise the base needs splitting.
5. **Cooling.** The stock fan blows sideways out a vent near the hinge. The design only has floor and lid slots, so the fan exhaust will recirculate inside the box. It needs a wall cutout lined up with the fan outlet.

## What's needed to finish
Calipers measurements of: board outline, 7 screw hole positions, each port's offset/width/height relative to the board, fan outlet position, and where you'll mount the DC jack and port daughterboard.

## Update after your context (bare board + IO boards + stock cooler, screen broken)
The file's approach (bare-board enclosure) matches what you want, so the structure is right. Items 1 to 5 above still apply. Additional things the enclosure needs:
- **Fan outlet cutout in a side wall** lined up with the stock cooler's exhaust (item 5), plus enough `over_h` for the heatsink/fan stack (28 mm is plenty; measure to confirm).
- **Mounts for the IO daughterboard(s)** and the DC-jack pigtail, which currently have no standoffs or cutouts.
- **Power button access.** The button is not on the mainboard on this model as far as I can tell (inferred), so it needs a cutout or a bridged momentary switch.
- **Lid sensor.** The x360 uses a magnet in the display half to detect lid closed / tablet mode. With the display removed the board may think the lid is closed or that it is in tablet mode. Test this before printing (inferred, not verified on this model).

## Getting a picture on an external monitor
- Once Windows/Linux loads, the board's own **HDMI port works normally**; the problem is only pre-OS (BIOS/POST) output going to the internal panel.
- **First test (free):** unplug the internal display ribbon completely at the board and boot with HDMI connected. On many laptops POST falls back to HDMI when no internal panel is detected. You said the BIOS shows only on the ribbon; if that was with the broken panel still attached, try it fully disconnected.
- **Cheapest reliable fix:** plug in any working 15.6" FHD 30-pin eDP panel (used/cracked-glass panels are cheap) just for BIOS setup. Set boot order and "power on AC" once, then run the board on HDMI.
- **eDP to DP adapter:** eDP uses DisplayPort signalling (same lanes, AUX channel and hot-plug pin), so a 30-pin eDP to DisplayPort breakout board can drive a regular DP monitor. They're sold for exactly this use (search "30pin eDP to DP adapter"). Caveats: the eDP connector carries panel and backlight power that must not reach the monitor, and some boards/monitors don't negotiate the link. Treat it as likely-but-not-guaranteed (inferred from the standards, not tested on this board). If you go this route, the case needs a DP cutout for it.
- Not a fix: eDP to **HDMI** needs an active converter chip, so a DP-out breakout plus a DP monitor (or a DP-to-HDMI active adapter) is simpler.

Sources: HP spec sheet you shared; HP m6-aq0xx/aq1xx service guide (https://manualsnet.com/hp/envy-15-aq000-x360); forum reports on board-only BIOS output (https://community.frame.work/t/can-the-bios-on-a-board-only-set-up-be-viewed-on-a-secondary-monitor/84540, https://smallformfactor.net/forum/threads/possible-bios-vbios-issue-with-laptop-i-want-to-turn-it-into-a-mini-sff-pc-but-due-to-a-manufacturer-problem-it-doesnt-output-properly.19772/latest).
