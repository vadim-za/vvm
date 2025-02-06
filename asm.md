Low-endian architecture, 16-bit address space

Byte registers: B0, B1, B2, B3, B4, B5, B6, B7

Word (2-byte) registers: W0, W2, W4, W6 (W0=B1:B0, W2=B3:B2, W4=B5:B4, W6=B7:B6)

Additional byte registers: PSB (processor status byte)

Additional word registers: SP, PC

| Code | Command | Deciphering | Description |
| ---- | ------- | ----------- | ----------- |
| 00nnnmmm | MBR Bn,Wm | Move Byte Register | Bn:=Bm |
| 0100nnmm | MWR Wn,Wm | Move Word Register | Wn:=Wm |
| 01010nnn lsb msb | LB Bn,Addr | Load Byte | Bn:=[Addr] |
| 01011nnn lsb msb | SB Bn,Addr | Store Byte | [Addr]:=Bn |
| 01100nnn value | LIB Bn,Value | Load Immediate Byte | Bn:=Value |
| 011010nn lsb msb | LW Wn,Addr | Load Word | Wn:=[Addr] |
| 011011nn lsb msb | SW Wn,Addr | Store Word | [Addr]:=Wn |
| 011100nn lsb msb | LIW Wn,Value | Load Immediate Word | Wn:=Value |
| ... | ... | ... |
| 10000nnn | ADB B0,Bn | Add Byte | B0:=B0+Bn |
| 10001nnn | SUB B0,Bn | Subtract Byte | B0:=B0-Bn |
| 100100nn | ADW W0,Wn | Add Word | W0:=W0+Bn |
| 100101nn | SUW W0,Wn | Subtract Word | W0:=W0-Bn |
| ... | ... | ... |
| ... | ACB | Add Carry to Byte | B0:=B0+C |
| ... | SCB | Subtract Carry from Byte | B0:=B0-C |
| ... | ACW | Add Carry to Word | W0:=W0+C |
| ... | SCW | Subtract Carry from Word | W0:=W0-C |

Examples:

| Code | Command | Action |
| ---- | ------- | ------ |
| 00001010 | MBR B1,B2 | copy B2 into B1 |
| 01001011 | MWR W4,W6 | copy W6 into W4 |

