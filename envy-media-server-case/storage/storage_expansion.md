# Storage expansion for the m6-aq103dx media server (2026-10-19)

Platform checked against the HP service guide: Intel i5-7200U (Kaby Lake, 15 W), mainboard **15257-2N / 448.07N07.002N**, 45 W HP Smart adapter (19.5 V), one 2.5" SATA bay on a flex cable (HP part **856788-001**), M.2 2280 SSD slot (you already boot NVMe from it), Intel 7265 Wi-Fi card (M.2 2230, A/E key). No Ethernet port on this laptop.

## 1. "Swap the ribbon for a real SATA port": no soldering needed
The board-side connector is a ZIF flex connector (the black latch, "purple tag" cable in iFixit's guide). The flex cable **already ends in a standard 22-pin SATA plug** (7-pin data + 15-pin power) that the 2.5" drive pushes onto.
- **Do:** keep the HP cable plugged into the board and add a **SATA 22-pin (7+15) male-to-female extension cable** (about 20-30 cm). The far end is a normal SATA socket you can mount in the case or plug any 2.5" drive into. If the HP cable is lost, buy 856788-001 (cheap on eBay/AliExpress).
- **Don't:** desolder the ZIF connector to fit a desktop 7-pin header. The flex carries the drive's 5 V power too, the pinout isn't published, and hand-wired high-speed SATA lanes tend to give link errors.
- **Limit:** that port only supplies **5 V, no 12 V**, so it runs one 2.5" drive (HDD or SSD). A 3.5" drive on it needs a separate 12 V + 5 V supply with grounds tied together. One port only; SATA port multipliers are unsupported on Intel AHCI controllers, so they won't add drives.

## 2. Adding several HDDs (best first)
**A. External multi-bay USB enclosure (recommended).** A 2- or 4-bay 3.5" enclosure with its own power brick (UASP, "JBOD"/single-disk mode, not hardware RAID) on one USB-A 3.1 Gen 1 port. 5 Gbps shared is far more than media streaming needs. Zero board risk and the drives' power is completely off the laptop's 45 W adapter. Pool with mergerfs + SnapRAID (good fit for media), or plain separate disks.

**B. Move the OS to the SATA bay, use the M.2 slot for a SATA controller.** Put the OS on a 2.5" SATA SSD on the HP cable, then fit an **M.2 M-key to 5x SATA card (JMB585 chip)** in the 2280 slot. Gives 5 native SATA ports inside the case. Needs: a separate PSU for the drives (an ATX/SFX PSU or a 12 V brick + 12 V-to-5 V board), short SATA cables routed out of the board area. Inferred: the slot is PCIe since your NVMe drive works; I couldn't confirm its lane count, and the JMB585 is fine on x2 or x4.

**C. Wi-Fi slot to SATA.** An **M.2 A+E key to 2x SATA adapter (ASM1061 or JMB582)** in place of the Wi-Fi card. Adds 2 ports and keeps the NVMe for the OS. You lose Wi-Fi, which you'd want to replace with a USB 3 gigabit Ethernet dongle anyway. Risks (inferred, not tested on this board): some HP BIOSes whitelist Wi-Fi cards and refuse to boot, and that slot is only PCIe x1. Try it before designing the case around it.

**Ethernet:** whichever you pick, a USB 3 gigabit Ethernet adapter (Realtek RTL8153 or similar) on the other USB-A port; Wi-Fi is a poor link for a media server.

## 3. Unpopulated pads worth soldering
I couldn't find a public schematic or boardview for 15257-2N, so I can't name specific footprints. Things to know:
- Kaby Lake-U's extra SATA/PCIe lanes only exist on the board if HP routed traces to a footprint; if they did, they'd be for a second M.2 or SATA connector. A missing connector usually also lacks its AC-coupling capacitors and power parts, so it's a rework job, not just a connector.
- Debug headers on HP boards are for EC/BIOS flashing, not useful for storage.
- If you post clear, well-lit photos of **both sides** of the board, I'll mark any empty connector footprints and say whether they look complete.

## 4. Power budget
The board is ~10-15 W at idle and ~30 W under load out of a 45 W adapter. One 2.5" HDD (~2.5 W, ~5 W spin-up) on the internal port is fine. Any 3.5" drives (~6-8 W each, ~25 W at spin-up) must be on their own supply (options A/B/C all assume this).

## 5. What the case needs (for the case thread)
- **Option A:** nothing internal; vents and USB clearance only. Optional slot for a 2.5" drive on the HP cable: 100 x 69.85 x 9.5 mm (7 mm drives fit too), M3 screws, standard SFF-8201 hole pattern (check against the real drive with calipers).
- **Option B/C:** 3.5" bays at 147 x 101.6 x 26.1 mm per drive, 6-32 UNC screws on the standard SFF-8301 pattern (check against the real drive), at least 10 mm air gap between drives with a fan across them, a panel cutout for the drive PSU input (IEC C14 or barrel jack), and a cable path 10 mm wide from the M.2 area to the bays.
- A 2.5" SATA socket mount for the extension cable end, if the boot SSD sits outside the original bay position.

## Sources
- HP ENVY x360 m6-aq0xx/aq1xx service guide: https://manualsnet.com/hp/envy-15-aq000-x360
- iFixit, m6-aq103dx hard drive replacement: https://kiwix.colibox.colibris-outilslibres.org/ifixit_fr_all_2022-08/C/Tutoriel/HP%2BEnvy%2Bx360%2Bm6-aq103dx%2BHard%2Bdrive%2BReplacement/98654
- HP forum on the 15-aq M.2 slot (SATA vs NVMe): https://h30434.www3.hp.com/t5/Notebook-Hardware-and-Upgrade-Questions/adding-SSD/m-p/9648643
- Board part number: https://www.gotlaptopparts.com/products/hp-envy-x360-m6-aq103dx-15-6-intel-i5-7200u-2-5ghz-motherboard-448-07n07-002n

## 6. Chosen route (user, 2026-10-19): USB, drives inside the case
A short USB 3 cable leaves a board USB-A port on the outside and comes back in through a hole into an HDD section of the case. Defaults picked (change if you like): **2 x 3.5" HDDs**, room left for a 3rd and 4th later, each drive on a powered **USB 3 to SATA adapter (UASP)** or one multi-bay USB-SATA bridge board, all powered from one **12 V 5 A brick**, never from the laptop adapter.

Bay requirements for the case:
- **Drive cradles:** 147 x 101.6 x 26.1 mm per 3.5" drive, held by 4 x 6-32 UNC side screws (SFF-8301 side holes; check with calipers) with rubber grommets for vibration. Drives on edge or flat, 10 mm air gap between them.
- **Airflow:** one 80 or 92 mm fan blowing across the drives, separate from the board's own vents; the drive section can be partitioned from the board section.
- **USB re-entry:** a 15 x 10 mm pass-through slot or grommet near the HDD section, close to the board's USB-A port so the outside loop is short (under 30 cm). A strain-relief clip inside.
- **Bridge/adapter mount:** a flat spot with M2.5/M3 standoffs for the USB-SATA adapter board(s), or a USB 3 hub if using one adapter per drive.
- **Power:** a 5.5 x 2.1 mm DC barrel jack panel hole (about 8 mm) for the 12 V brick, plus room for a small 12 V to 5 V buck board and a SATA power splitter.
- **Printer size:** two 3.5" drives side by side add roughly 120 x 160 mm of footprint; the HDD section may need to print as a separate module that bolts onto the board case.

**Clarified (user, 2026-10-19): one USB-to-SATA adapter cable per drive.**
- 2.5" drives: plain bus-powered USB 3 to SATA cables are fine, one per USB port.
- 3.5" drives: the adapter must be the kind with a 12 V barrel input. Feed all of them from one 12 V 5 A brick through a 5.5 x 2.1 mm splitter rather than one brick each.
- Ports: the board has 2x USB-A + 1x USB-C, and one will go to Ethernet. With more than 2 drives, put a powered USB 3 hub (UASP-friendly, e.g. VIA VL817 or Genesys GL3523) inside the HDD section, so only one cable loops out and back in. The case then needs a mount for the hub instead of a bridge board.
- Adapter bodies need about 60 mm of clearance behind each drive's SATA connector for the plug, the adapter body and the cable bend.
