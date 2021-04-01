# This file specifies how the pads are placed
# The name of each pad here has to match the
# name in the verilog code
# The target padframe has 4 corners cells and 40 side pads
# Each side should have at least 1 vdd/gnd pair
# Use filler cells (PADNC) to fill up each side to 10 pads each
# Each pad instance needs it's orientation specified

Version: 2

Orient: R0
Pad: NC1 NW PADFC # Top left corner pad
Orient: R0
Pad: U5 N
Orient: R0
Pad: ND5 N PADNC # Dummy 5
Orient: R0
Pad: ND6 N PADNC # Dummy 6
Orient: R0
Pad: ND7 N PADNC # Dummy 7
Orient: R0
Pad: P0 N PADVDD
Orient: R0
Pad: G0 N PADGND
Orient: R0
Pad: ND8 N PADNC # Dummy 8
Orient: R0
Pad: ND9 N PADNC # Dummy 9
Orient: R0
Pad: ND10 N PADNC # Dummy 10
Orient: R0
Pad: U6 N
Orient: R270
Pad: NC2 NE PADFC # Top right corner pad

Orient: R90
Pad: WD5 W PADNC # Dummy 5
Orient: R90
Pad: WD6 W PADNC # Dummy 6
Orient: R90
Pad: U1 W
Orient: R90
Pad: WD7 W PADNC # Dummy 7
Orient: R90
Pad: P1 W PADVDD
Orient: R90
Pad: G1 W PADGND
Orient: R90
Pad: WD8 W PADNC # Dummy 8
Orient: R90
Pad: U2 W
Orient: R90
Pad: WD9 W PADNC # Dummy 9
Orient: R90
Pad: WD10 W PADNC # Dummy 10

Orient: R90
Pad: SC1 SW PADFC # Bottom left corner pad
Orient: R180
Pad: U8 S
Orient: R180
Pad: U9 S
Orient: R180
Pad: U10 S
Orient: R180
Pad: U11 S
Orient: R180
Pad: P2 S PADVDD
Orient: R180
Pad: G2 S PADGND
Orient: R180
Pad: U12 S
Orient: R180
Pad: U13 S
Orient: R180
Pad: U14 S
Orient: R180
Pad: U15 S
Orient: R180
Pad: SC2 SE PADFC # Bottom right corner pad

Orient: R270
Pad: ED7 E PADNC # Dummy 7
Orient: R270
Pad: U3 E
Orient: R270
Pad: U4 E
Orient: R270
Pad: ED8 E PADNC # Dummy 8
Orient: R270
Pad: P3 E PADVDD
Orient: R270
Pad: G3 E PADGND
Orient: R270
Pad: ED9 E PADNC # Dummy 9
Orient: R270
Pad: U7 E
Orient: R270
Pad: U16 E
Orient: R270
Pad: ED10 E PADNC # Dummy 10

