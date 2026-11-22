# Parts list: Envy media server box

All links are Daraz Nepal. "Search" links open a Daraz search because no single listing was confirmed; pick any listing that matches the spec.

| Qty | Part | Link | Why |
|---|---|---|---|
| 1 | 4-port USB 3.0 hub with power input | [Daraz](https://www.daraz.com.np/products/high-speed-usb-hub-4-port-usb-30-adapter-with-power-supply-otg-extension-for-laptop-macbook-pc-computer-usb-30-hub-i130007574.html) | The USB splitter. Sits in the cradle; its cable loops out to the board. Pick one about 100 × 30 × 13 mm, or change hub_size in the file. |
| 3 | USB 3.0 to SATA cable with DC power input | [Daraz](https://www.daraz.com.np/products/sata-to-usb-30-2535-hdd-ssd-hard-drive-converter-cable-line-adapter-i105951468.html) | One per drive. 3.5" drives take 12 V into its DC input from the splitter; 2.5" drives run on USB power alone. |
| 1 | 12 V 5 A SMPS power adapter (5.5 × 2.1 mm) | [Daraz](https://www.daraz.com.np/products/multipurpose-12v-5a-60w-smps-dc-power-supply-for-cctv-led-i103524332.html) | The one brick for drives, fans and hub. Separate from the laptop charger. |
| 1 | DC power splitter, 1 female to 4 male, 5.5 × 2.1 mm | [Daraz search](https://www.daraz.com.np/catalog/?q=dc+power+splitter+1+to+4+5.5x2.1) | Inside the box: jack to each 3.5" adapter, the fans and the 5 V converter. Get a 1-to-5 or two of them for 4 drives. |
| 1 | DC-022 panel-mount jack, 5.5 × 2.1 mm | [Daraz search](https://www.daraz.com.np/catalog/?q=dc+022+dc+jack+panel) | Goes in the 11 mm hole in the right wall. Check yours; if its thread is smaller, change dc12_d. |
| 1 | 12 V to 5 V step-down converter (3 A or more) | [Daraz](https://www.daraz.com.np/products/rcnun-12v-24v-to-5v-3a-5a-10a-step-down-dc-dc-converter-regulator-50w-24-12-volt-buck-to-5-volt-led-power-supply-for-cars-i464614289.html) | Powers the hub from the 12 V brick, so you need only one wall plug. Skip it if you'd rather use the hub's own adapter. |
| 1 | 80 mm 12 V fan (intake) | [Daraz search](https://www.daraz.com.np/catalog/?q=80mm+12v+cooling+fan) | Left wall, pulls air across the drives. 80 × 80 × 25 mm, 71.5 mm screw spacing. |
| 1 | 60 mm 12 V fan (exhaust) | [Daraz search](https://www.daraz.com.np/catalog/?q=60mm+12v+cooling+fan) | Inside the back wall, high up above the adapters, pushes warm air out. 50 mm screw spacing. |
| 3 | DC 5.5 × 2.1 mm male pigtail leads | [Daraz search](https://www.daraz.com.np/catalog/?q=dc+male+pigtail+5.5x2.1+cable) | To wire the two fans and the 5 V converter onto the splitter. |
| 1 | 12 mm momentary push button | [Daraz](https://www.daraz.com.np/products/black-10x-pcs-12mm-waterproof-momentary-onoff-push-button-round-spst-switch-i128398424-s1035877039.html) | Front-wall power button, wired to the board's power-button pads. Must be momentary, not latching. |
| 1 set | HDD screws (6-32) and rubber grommets | [Daraz search](https://www.daraz.com.np/catalog/?q=hdd+screw+set+6-32) | 2 per 3.5" drive through the shelf. The set usually includes M3 screws for 2.5" drives too. |
| 1 set | M3 screws, 8 to 12 mm | [Daraz search](https://www.daraz.com.np/catalog/?q=m3+screw+set) | 4 for the lid, 8 for the fans. The board reuses its original HP M2 screws. |
| 1 pack | Small zip ties | [Daraz search](https://www.daraz.com.np/catalog/?q=zip+ties+small) | Two hold the hub in its cradle, one holds the hub cable at the slot. |

Wiring: 12 V brick → panel jack → 1-to-4 splitter → each 3.5" adapter, intake fan, exhaust fan, 12→5 V converter → hub power. The hub's USB cable goes out the slot to the board's right USB-A port. 2.5" drives need no 12 V.
