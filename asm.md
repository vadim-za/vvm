Low-endian architecture, 16-bit address space

| Entity kind | Instances |
| ----------- | --------- |
| Byte registers | B0, B1, B2, B3, B4, B5, B6, B7 |
| Word (2-byte) registers | W0, W1, W2, W3 (where W0=B1:B0, W1=B3:B2, W2=B5:B4, W3=B7:B6) |
| Additional word registers | PC (program counter), A (accumulator), X (accumulator eXtension), ADDR (address register) |

| Code | Command | Deciphering | Description |
| ---- | ------- | ----------- | ----------- |
| 00000nnn | LBR Bn | Load from Byte Register | LSB(A):=Bn |
| 000010nn | LWR Wn | Load from Word Register | A:=Wn |
| ... |
| 00010nnn | STBR Bn | STore to Byte Register | Bn:=LSB(A) |
| 000110nn | STWR Wn | STore to Word Register | Wn:=A |
| ... |
| 00100nnn | XBR Bn | eXchange Byte Register | LSB(A)<->Bn |
| 001010nn | XWR Wn | eXchange Word Register | A<->Wn |
| ... |
| 0011000v | JIF7 v | Jump IF bit 7 equals v | if(A[7]==v) PC:=ADDR |
| 0011001v | JIF8 v | Jump IF bit 8 equals v | if(A[8]==v) PC:=ADDR |
| 00110100 | JIFZB | Jump IF Zero Byte | if(LSB(A)==0) PC:=ADDR |
| 00110101 | JIFNZB | Jump IF Non-Zero Byte | if(LSB(A)!=0) PC:=ADDR |
| ... |
| 0011100v | JIF15 v | Jump IF bit 15 equals v | if(A[15]==v) PC:=ADDR |
| 0011101v | JIF16 v | Jump IF bit 16 equals v | if(X[0]==v) PC:=ADDR |
| 00111100 | JIFZW | Jump IF Zero Word | if(A==0) PC:=ADDR |
| 00111101 | JIFNZW | Jump IF Non-Zero Word | if(A!=0) PC:=ADDR |
| ... |
| 01000000 | ADD | Add, producing 32-bit result in (X:A)  | (X:A):=A+X |
| 01000001 | SUB | Subtract, producing 32-bit result in (X:A) | (X:A):=A-X |
| 01000010 | AND | Bitwise And | A:=A&X |
| 01000011 | OR | Bitwise Or | A:=A\|X |
| 01000100 | XOR | Bitwise Xor | A:=A^X |
| 01000101 | JMP | Jump (unconditionally) | PC:=ADDR |
| 01000110 | CALL | Call | SP:=SP-2, [SP]:=PC, PC:=ADDR |
| 01000111 | RET | Return | PC:=[SP], SP:=SP+2 |
| 010010nn | ARWR Wn | Address Register from Word Register | ADDR:=Wn |
| ... |
| 01010000 | ZERO | Zero the accumulator | A:=0 |
| 01010001 | ALL | Set all accumulator bits | A:=0xFFFF |
| 01010010 | CPL | Complement all accumulator bits | A:=~A |
| 01010011 | XHL | eXchange accumulator's HSB and LSB | HSB(A)<->LSB(A) |
| ... |
| 01011000 | ROL | ROtate extended accumulator Left | (X:A):=ROL(X:A) |
| 01011001 | ROR | ROtate extended accumulator Right | (X:A):=ROR(X:A) |
| 01011010 | NOP | No-operation | Do nothing |
| 01011011 | XA | eXchange the accumulators | X<->A |
| ... |
| 01100000 | LBI | Load Byte Indirect | LSB(A):=[ADDR] |
| 01100001 Byte | LBV Byte | Load Byte Value | LSB(A):=Byte |
| 01100010 | IN | Input: read from port | LSB(A):=Port[LSB(ADDR)] |
| ... |
| 01101000 | LWI | Load Word Indirect | A:=[ADDR] |
| 01101001 LSB HSB | LWV Word | Load Word Value | A:=Word |
| 01101010 | LSP | Load Stack Pointer | A:=SP |
| 01101011 | POP | Pop from stack | A:=[SP], SP:=SP+2 |
| ... |
| 01110000 | STBI | STore Byte Indirect | [ADDR]:=LSB(A) |
| 01110001 | ARA | Address Register from Accumulator | ADDR:=A |
| 01110010 | OUT | Output: write into port | Port[LSB(ADDR)]:=LSB(A) |
| ... |
| 01110100 | SXBW | Sign eXtend Byte to Word | A:=SignExtend(LSB(A)) |
| 01110101 | CXBW | Copy-eXtend Byte to Word | HSB(A):=LSB(A) |
| 01110110 | ZXBW | Zero-eXtend Byte to Word | HSB(A):=0 |
| 01110111 | AXBW | All-eXtend Byte to Word | HSB(A):=0xFF |
| 01111000 | STWI | STore Word Indirect | [ADDR]:=A |
| 01111001 LSB HSB | ARV Word | Address Register from Value | ADDR:=Word |
| 01111010 | STSP | STore into Stack Pointer | SP:=A |
| 01111011 | PUSH | Push to stack | SP:=SP-2, [SP]:=A |
| 01111100 | SXWX | Sign eXtend Word to eXtended | (X:A):=SignExtend(LSB(A)) |
| 01111101 | CXWX | Copy-eXtend Word to eXtended | X:=A |
| 01111110 | ZXWX | Zero-eXtend Word to eXtended | X:=0 |
| 01111111 | AXWX | All-eXtend Word to eXtended | X:=0xFFFF |



|   | x0 | x1 | x2 | x3 | x4 | x5 | x6 | x7 | x8 | x9 | xA | xB | xC | xD | xE | xF |
| - | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| **0x** | LBR B0 | LBR B1 | LBR B2 | LBR B3 | LBR B4 | LBR B5 | LBR B6 | LBR B7 | LWR W0 | LWR W1 | LWR W2 | LWR W3
| **1x** | STBR B0 | STBR B1 | STBR B2 | STBR B3 | STBR B4 | STBR B5 | STBR B6 | STBR B7 | STWR W0 | STWR W1 | STWR W2 | STWR W3 
| **2x** | XBR B0 | XBR B1 | XBR B2 | XBR B3 | XBR B4 | XBR B5 | XBR B6 | XBR B7 | XWR W0 | XWR W1 | XWR W2 | XWR W3 
| **3x** | JIF7 0 | JIF7 1 | JIF8 0 | JIF8 1 | JIFZB | JIFNZB | | | JIF15 0 | JIF15 1 | JIF16 0 | JIF16 1 | JIFZW | JIFNZW |
| **4x** | ADD | SUB |  AND | OR | XOR | JMP | CALL | RET | ARWR W0 | ARWR W1 | ARWR W2 | ARWR W3
| **5x** | ZERO | ALL | CPL | XHL | | | | | ROL | ROR | NOP | XA |
| **6x** | LBI | LBV Byte | IN | | | | | | LWI | LWV Word | LSP | POP
| **7x** | STBI | ARA | OUT | | SXBW | CXBW | ZXBW | AXBW | STWI | ARV Word | STSP | PUSH | SXWX | CXWX | ZXWX | AXWX
