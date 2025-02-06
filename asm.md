Low-endian architecture, 16-bit address space

| Entity kind | Instances |
| ----------- | --------- |
| Byte registers | B0, B1, B2, B3, B4, B5, B6, B7 |
| Word (2-byte) registers | W0, W1, W2, W3 (where W0=B1:B0, W1=B3:B2, W2=B5:B4, W3=B7:B6) |
| Additional byte registers | PSB (processor status byte) |
| Additional word registers | PS, PC, A (accumulator), ADDR (address register) |

| Code | Command | Deciphering | Description |
| ---- | ------- | ----------- | ----------- |
| 00000nnn | LBR Bn | Load from Byte Register | LSB(A):=Bn |
| 00001nnn | STBR Bn | STore to Byte Register | Bn:=LSB(A) |
| 00010nnn | ABR Bn | Add Byte Register | LSB(A):=LSB(A)+Bn, update ZF,SF,CF |
| 00011nnn | SBR Bn | Subtract Byte Register | LSB(A):=LSB(A)-Bn, update ZF,SF,CF |
| 00100nnn | BABR Bn | Bitwise-And Byte Register | LSB(A):=LSB(A)&Bn, update ZF,SF,CF |
| 00101nnn | BOBR Bn | Bitwise-Or Byte Register | LSB(A):=LSB(A)\|Bn, update ZF,SF,CF |
| 00110nnn | BXBR Bn | Bitwise-Xor Byte Register | LSB(A):=LSB(A)^Bn, update ZF,SF,CF |
| 00111nnn | XBR Bn | eXchange Byte Register | LSB(A)<->Bn |
| 01000nn0 | LWR Wn | | |
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
| **0x** | LBR B0 | LBR B1 | LBR B2 | LBR B3 | LBR B4 | LBR B5 | LBR B6 | LBR B7 | LWR W0 | LWR W1 | LWR W2 | LWR W3
| **1x** | STBR B0 | STBR B1 | STBR B2 | STBR B3 | STBR B4 | STBR B5 | STBR B6 | STBR B7 | STWR W0 | STWR W1 | STWR W2 | STWR W3 
| **2x** | XBR B0 | XBR B1 | XBR B2 | XBR B3 | XBR B4 | XBR B5 | XBR B6 | XBR B7 | XWR W0 | XWR W1 | XWR W2 | XWR W3 
| **3x** | IF7 0 | IF7 1 | IF8 0 | IF8 1 | IFZB | IFNZB | SXBW | ZXBW | IF15 0 | IF15 1 | IF16 0 | IF16 1 | IFZW | IFNZW | SXWX | ZXWX |
| **4x** | ADD | SUB |  AND | OR | XOR | JMP | CALL | RET | ARWR W0 | ARWR W1 | ARWR W2 | ARWR W3
| **5x** | ADDC | SUBC | ZERO | ALL | CPL | XHL | CXBW | AXBW | ROL | ROR | | | | XA | CXWX | AXWX
| **6x** | LBI | LBV Byte | IN | | | | | | LWI | LWV Word | LSP | POP
| **7x** | STBI | ARA | OUT | | | | | | STWI | ARV Word | STSP | PUSH
