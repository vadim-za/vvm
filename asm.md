Low-endian architecture, 16-bit address space

| Entity kind | Instances |
| ----------- | --------- |
| Byte registers | B0, B1, B2, B3, B4, B5, B6, B7 |
| Word (2-byte) registers | W0, W2, W4, W6 (where W0=B1:B0, W2=B3:B2, W4=B5:B4, W6=B7:B6) |
| Additional byte registers | PSB (processor status byte) |
| Additional word registers | SP, PC, A (accumulator), ADDR (address register) |

| Code | Command | Deciphering | Description |
| ---- | ------- | ----------- | ----------- |
| 00000nnn | LBR Bn | Load from Byte Register | LSB(A):=Bn |
| 00001nnn | STBR Bn | STore to Byte Register | Bn:=LSB(A) |
| 00010nnn | ABR Bn | Add Byte Register | LSB(A):=LSB(A)+Bn, update PSB |
| 00011nnn | SBR Bn | Subtract Byte Register | LSB(A):=LSB(A)-Bn, update PSB |
| 00100nnn | BABR Bn | Bitwise-And Byte Register | LSB(A):=LSB(A)&Bn, update ZF,SF |
| 00101nnn | BOBR Bn | Bitwise-Or Byte Register | LSB(A):=LSB(A)\|Bn, update ZF,SF |
| 00110nnn | BXBR Bn | Bitwise-Xor Byte Register | LSB(A):=LSB(A)^Bn, update ZF,SF |
| 00111nnn | XBR Bn | eXchange Byte Register | LSB(A)<->Bn |
| 010000nn | LWR Wn | | |
| 010001nn | STWR Wn | | |
| 010010nn | AWR Wn | | |
| 010011nn | SWR Wn | | |
| 010100nn | BAWR Wn | | |
| 010101nn | BOWR Wn | | |
| 010110nn | BXWR Wn | | |
| 010111nn | XWR Wn | | |
| ... | ... | | |
| ... | LBI | Load Byte Indirect | LSB(A):=[ADDR] |
| ... | STBI | STore Byte Indirect | [ADDR]:=LSB(A) |
| ... | TESTB | set flags according to accumulator Byte | update ZF,SF |
| ... | ZB | Zero accumulator Byte | LSB(A):=0 |
| ... | ABC | Add Byte Carry | LSB(A):=LSB(A)+CF, update PSB |
| ... | SBC | Subtract Byte Carry | LSB(A):=LSB(A)-CF, update PSB |
| ... | RBL | Rotate Byte Left | (CF:LSB(A)):=RotL(CF:LSB(A)), update SF,ZF |
| ... | RBR | Rotate Byte Right | (CF:LSB(A)):=RotR(CF:LSB(A)), update SF,ZF |
| ... | SXBC | Sign eXtend Byte to Carry | CF:=Bit7(A) |
| ... | LBV ByteValue | Load Byte Value | LSB(A):=ByteValue |
| ... | ... | | |
| ... | LWI | Load Word Indirect | A:=[ADDR] |
| ... | STWI | STore Word Indirect | [ADDR]:=A |
| ... | TESTW | set flags according to accumulator Word | update ZF,SF |
| ... | ZW | Zero accumulator Word | A:=0 |
| ... | AWC | Add Word Carry | A:=A+CF, update PSB |
| ... | SWC | Subtract Word Carry | A:=A-CF, update PSB |
| ... | RWL | Rotate Word Left | (CF:A):=RotL(CF:A), update SF,ZF |
| ... | RWR | Rotate Word Right | (CF:A):=RotR(CF:A), update SF,ZF |
| ... | SXWC | Sign eXtend Word to Carry | CF:=Bit15(A) |
| ... | LWV WordValue | Load Word Value | A:=ByteValue |
| ... | ... | | |
| ... | ARV WordValue | Address Register from Value | ADDR:=Value |
| ... | ARWR Wn | Address Register from Word Register | ADDR:=Wn |
| ... | ARA | Address Register from Accumulator | ADDR:=A |
| ... | ARSP | Address Register from Stack Pointer | ADDR:=A |
| ... | JMP | Jump to address | PC:=ADDR |
| ... | PUSH | Push to stack | SP:=SP-2, [SP]:=A |
| ... | POP | POP from stack | A:=[SP], SP:=SP+2 |
| ... | RET | Return | PC:=[SP], SP:=SP+2 |
| ... | CALL | Call to address | SP:=SP-2, [SP]:=PC, PC:=ADDR |
| ... | ... | | |
| ... | SCV BitValue | Set Carry Value | CF:=Value |
| ... | SCL  | Set Carry from Lowest significant bit | CF:=Bit0(A) |
| ... | SXBW | Sign eXtend Byte to Word | A:=SignExtend(LSB(A)) |
| ... | XB | eXchange accumulator Bytes | LSB(A)<->HSB(A) |
| ... | LSP | Load from Stack Pointer | A:=SP |
| ... | STSP | Store to Stack Pointer | SP:=A |
| ... | IFC v | If Carry flag | if CF==v |
| ... | IFZ v | If Zero flag | if ZF==v |
| ... | IFS v | If Sign flag | if SF==v |



|   | x0 | x1 | x2 | x3 | x4 | x5 | x6 | x7 | x8 | x9 | xA | xB | xC | xD | xE | xF |
| - | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| **0x** | LBR B0 | LBR B1 | LBR B2 | LBR B3 | LBR B4 | LBR B5 | LBR B6 | LBR B7 | STBR B0 | STBR B1 | STBR B2 | STBR B3 | STBR B4 | STBR B5 | STBR B6 | STBR B7 |
| **1x** | ABR B0 | ABR B1 | ABR B2 | ABR B3 | ABR B4 | ABR B5 | ABR B6 | ABR B7 | SBR B0 | SBR B1 | SBR B2 | SBR B3 | SBR B4 | SBR B5 | SBR B6 | SBR B7 |
| **2x** | BABR B0 | BABR B1 | BABR B2 | BABR B3 | BABR B4 | BABR B5 | BABR B6 | BABR B7 | BOBR B0 | BOBR B1 | BOBR B2 | BOBR B3 | BOBR B4 | BOBR B5 | BOBR B6 | BOBR B7 |
| **3x** | BXBR B0 | BXBR B1 | BXBR B2 | BXBR B3 | BXBR B4 | BXBR B5 | BXBR B6 | BXBR B7 | XBR B0 | XBR B1 | XBR B2 | XBR B3 | XBR B4 | XBR B5 | XBR B6 | XBR B7 |
| **4x** | LWR W0 | | LWR W2 | | LWR W4 | | LWR W6 | | STWR W0 | | STWR W2 | | STWR W4 | | STWR W6 | |
| **5x** | AWR W0 | | AWR W2 | | AWR W4 | | AWR W6 | | SWR W0 | | SWR W2 | | SWR W4 | | SWR W6 | |
| **6x** | BAWR W0 | | BAWR W2 | | BAWR W4 | | BAWR W6 | | BOWR W0 | | BOWR W2 | | BOWR W4 | | BOWR W6 |
| **7x** | BXWR W0 | | BXWR W2 | | BXWR W4 | | BXWR W6 | | XWR W0 | | XWR W2 | | XWR W4 | | XWR W6 |
| **8x** | ?LBR B0 | LBR B1 | LBR B2 | LBR B3 | LBR B4 | LBR B5 | LBR B6 | LBR B7 | ?STBR B0 | STBR B1 | STBR B2 | STBR B3 | STBR B4 | STBR B5 | STBR B6 | STBR B7 |
| **9x** | RABR B0 | RABR B1 | RABR B2 | RABR B3 | RABR B4 | RABR B5 | RABR B6 | RABR B7 | RSBR B0 | RSBR B1 | RSBR B2 | RSBR B3 | RSBR B4 | RSBR B5 | RSBR B6 | RSBR B7 |
| **Ax** | RBABR B0 | RBABR B1 | RBABR B2 | RBABR B3 | RBABR B4 | RBABR B5 | RBABR B6 | RBABR B7 | RBOBR B0 | RBOBR B1 | RBOBR B2 | RBOBR B3 | RBOBR B4 | RBOBR B5 | RBOBR B6 | RBOBR B7 |
| **Bx** | RBXBR B0 | RBXBR B1 | RBXBR B2 | RBXBR B3 | RBXBR B4 | RBXBR B5 | RBXBR B6 | RBXBR B7 | ?XBR B0 | XBR B1 | XBR B2 | XBR B3 | XBR B4 | XBR B5 | XBR B6 | XBR B7 |
| **Cx** | ?LWR W0 | | LWR W2 | | LWR W4 | | LWR W6 | | ARWR W0 | | ARWR W2 | | ARWR W4 | | ARWR W6 | |
| **Dx** | RAWR W0 | | RAWR W2 | | RAWR W4 | | RAWR W6 | | RSWR W0 | | RSWR W2 | | RSWR W4 | | RSWR W6 | |
| **Ex** | RBAWR W0 | | RBAWR W2 | | RBAWR W4 | | RBAWR W6 | | RBOWR W0 | | RBOWR W2 | | RBOWR W4 | | RBOWR W6 |
| **Fx** | RBXWR W0 | | RBXWR W2 | | RBXWR W4 | | RBXWR W6 | | ?XWR W0 | | XWR W2 | | XWR W4 | | XWR W6 |



|   | x0 | x1 | x2 | x3 | x4 | x5 | x6 | x7 | x8 | x9 | xA | xB | xC | xD | xE | xF |
| - | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| **4x** | LBI | LBV Byte | | | | | | IN | STBI | SCL | SCV 0 | SCV 1 | | | | OUT |
| **5x** | ABC | RBL | SXBC | | | | | | SBC | RBR | | | | | | |
| **6x** | TESTB | | | | | | | | | | | | | | | |
| **7x** | ZB | CPLB | CPLC | | | | | | XBI | XB | IFC 0 | IFC 1 | IFZ 0 | IFZ 1 | IFS 0 | IFS 1 |
| **Cx** | LWI | LWV Word | LSP | POP | | | | | STWI | ARV Word | STSP | PUSH | | | ARA | ARSP |
| **Dx** | AWC | RWL | SXWC | RET | | | | | SWC | RWR | JMP | CALL | | | | |
| **Ex** | TESTW | | | | | | | | ARWR W0 | | ARWR W2 | | ARWR W4 | | ARWR W6 | |
| **Fx** | ZW | CPLW | | | | | | | XWI | NOP
