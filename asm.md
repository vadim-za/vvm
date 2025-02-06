Low-endian architecture, 16-bit address space

| Entity kind | Instances |
| ----------- | --------- |
| Byte registers | B0, B1, B2, B3, B4, B5, B6, B7 |
| Word (2-byte) registers | W0, W2, W4, W6 (where W0=B1:B0, W2=B3:B2, W4=B5:B4, W6=B7:B6) |
| Additional byte registers | PSB (processor status byte) |
| Additional word registers | SP, PC, A (accumulator) |

| Code | Command | Deciphering | Description |
| ---- | ------- | ----------- | ----------- |
| 00000nnn | LBR Bn | Load from Byte Register | LSB(A):=Bn |
| 00001nnn | STBR Bn | Store to Byte Register | Bn:=LSB(A) |
| 00010nnn | ABR Bn | Add Byte Register | LSB(A):=LSB(A)+Bn, update PSB |
| 00011nnn | SBR Bn | Subtract Byte Register | LSB(A):=LSB(A)-Bn, update PSB |
| 00100nnn | BABR Bn | Bitwise-And Byte Register | LSB(A):=LSB(A)&Bn, update ZF,SF |
| 00101nnn | BOBR Bn | Bitwise-Or Byte Register | LSB(A):=LSB(A)\|Bn, update ZF,SF |
| 00110nnn | BXBR Bn | Bitwise-Xor Byte Register | LSB(A):=LSB(A)^Bn, update ZF,SF |
| 00111nnn | XBR Bn | eXchange Byte Register | LSB(A)<->Bn |
| 010000nn | LWR Wn | | |
| 010001nn | SWR Wn | | |
| 010010nn | AWR Wn | | |
| 010011nn | STWR Wn | | |
| 010100nn | BAWR Wn | | |
| 010101nn | BOWR Wn | | |
| 010110nn | BXWR Wn | | |
| 010111nn | XWR Wn | | |
| 011000nn | LBI Wn | Load Byte Indirect | LSB(A):=[Wn] |
| 011001nn | STBI Wn | Store Byte Indirect | [Wn]:=LSB(A) |
| 011010nn | LWI Wn | Load Word Indirect | A:=[Wn] |
| 011011nn | STWI Wn | Store Word Indirect | [Wn]:=A |
| ... | ... | | |
| ... | TESTB | set flags according to accumulator Byte | update ZF,SF |
| ... | ZB | Zero accumulator Byte | LSB(A):=0 |
| ... | LBA Addr | Load Byte from Address | LSB(A):=[Addr] |
| ... | STBA Addr | Store Byte to Address | [Addr]:=LSB(A) |
| ... | ABC | Add Byte Carry | LSB(A):=LSB(A)+CF, update PSB |
| ... | SBC | Subtract Byte Carry | LSB(A):=LSB(A)-CF, update PSB |
| ... | RBL | Rotate Byte Left | (CF:LSB(A)):=RotL(CF:LSB(A)), update SF,ZF |
| ... | RBR | Rotate Byte Right | (CF:LSB(A)):=RotR(CF:LSB(A)), update SF,ZF |
| ... | SXBC | Sign eXtend Byte to Carry | CF:=Bit7(A) |
| ... | TESTW | set flags according to accumulator Word | update ZF,SF |
| ... | ZW | Zero accumulator Word | A:=0 |
| ... | LWA Addr | Load Word from Address | A:=[Addr] |
| ... | STWA Addr | Store Word to Address | [Addr]:=A |
| ... | AWC | Add Word Carry | A:=A+CF, update PSB |
| ... | SWC | Subtract Word Carry | A:=A-CF, update PSB |
| ... | RWL | Rotate Word Left | (CF:A):=RotL(CF:A), update SF,ZF |
| ... | RWR | Rotate Word Right | (CF:A):=RotR(CF:A), update SF,ZF |
| ... | SXWC | Sign eXtend Word to Carry | CF:=Bit15(A) |
| ... | LBV ByteValue | Load Byte Value | LSB(A):=ByteValue |
| ... | LCV BitValue | Load Carry Value | CF:=Value |
| ... | LCL  | Load Carry from Lowest significant bit | CF:=Bit0(A) |
| ... | SX | Sign eXtend | A:=SignExtend(LSB(A)) |
| ... | XB | eXchange accumulator Bytes | LSB(A)<->HSB(A) |
| ... | LSP | Load from Stack Pointer | A:=SP |
| ... | STSP | Store to Stack Pointer | SP:=A |
| ... | IFC v | If Carry flag | if CF==v |
| ... | IFZ v | If Zero flag | if ZF==v |
| ... | IFS v | If Sign flag | if SF==v |

Examples:

| Code | Command | Action |
| ---- | ------- | ------ |
| 00001010 | MBR B1,B2 | copy B2 into B1 |
| 01001011 | MWR W4,W6 | copy W6 into W4 |

