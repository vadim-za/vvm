# Vintage-like Virtual Machine - Basic Architecture

Low-endian architecture, 16-bit address space

| Entity kind | Instances |
| ----------- | --------- |
| Byte registers | B0, B1, B2, B3, B4, B5, B6, B7 |
| Word (2-byte) registers | W0, W1, W2, W3 (where W0=B1:B0, W1=B3:B2, W2=B5:B4, W3=B7:B6) |
| Additional word registers | PC (program counter), A (accumulator), X (accumulator eXtension), ADDR (address register) |

| Command | Deciphering | Description |
| ------- | ----------- | ----------- |
| LBR Bn | Load from Byte Register | LSB(A):=Bn |
| LWR Wn | Load from Word Register | A:=Wn |
| STBR Bn | STore to Byte Register | Bn:=LSB(A) |
| STWR Wn | STore to Word Register | Wn:=A |
| XBR Bn | eXchange Byte Register | LSB(A)<->Bn |
| XWR Wn | eXchange Word Register | A<->Wn |
| JIFLZ | Jump IF Low byte is Zero | if(LSB(A)==0) PC:=ADDR |
| JIFLNZ | Jump IF Low byte is Not Zero | if(LSB(A)!=0) PC:=ADDR |
| JIFHZ | Jump IF High byte is Zero | if(HSB(A)==0) PC:=ADDR |
| JIFHNZ | Jump IF High byte is Not Zero | if(HSB(A)!=0) PC:=ADDR |
| JIFZ | Jump IF accumulator is Zero | if(A==0) PC:=ADDR |
| JIFNZ | Jump IF accumulator is Not Zero | if(A!=0) PC:=ADDR |
| JIFXZ | Jump IF accumulator eXtension is Zero | if(X==0) PC:=ADDR |
| JIFXNZ | Jump IF accumulator eXtension is Not Zero | if(X!=0) PC:=ADDR |
| ADD | unsigned Add, 32-bit result in (X:A)  | (X:A):=A+X |
| SUB | unsigned Subtract, 32-bit result in (X:A) | (X:A):=A-X |
| AND | Bitwise And | A:=A&X |
| OR | Bitwise Or | A:=A\|X |
| XOR | Bitwise Xor | A:=A^X |
| JMP | Jump (unconditionally) | PC:=ADDR |
| CALL | Call | SP:=SP-2, [SP]:=PC, PC:=ADDR |
| RET | Return | PC:=[SP], SP:=SP+2 |
| ARWR Wn | Address Register from Word Register | ADDR:=Wn |
| ZERO | Zero the accumulator | A:=0 |
| ALL | Set all accumulator bits | A:=0xFFFF |
| CPL | Complement all accumulator bits | A:=~A |
| XHL | eXchange accumulator's HSB and LSB | HSB(A)<->LSB(A) |
| ROL | ROtate extended accumulator Left | (X:A):=ROL(X:A) |
| ROR | ROtate extended accumulator Right | (X:A):=ROR(X:A) |
| NOP | No-operation | Do nothing |
| XA | eXchange the accumulators | X<->A |
| LBI | Load Byte Indirect | LSB(A):=[ADDR] |
| LBV Byte | Load Byte Value | LSB(A):=Byte |
| IN | Input: read from port | LSB(A):=Port[LSB(ADDR)] |
| LWI | Load Word Indirect | A:=[ADDR] |
| LWV Word | Load Word Value | A:=Word |
| LSP | Load Stack Pointer | A:=SP |
| POP | Pop from stack | A:=[SP], SP:=SP+2 |
| STBI | STore Byte Indirect | [ADDR]:=LSB(A) |
| ARA | Address Register from Accumulator | ADDR:=A |
| OUT | Output: write into port | Port[LSB(ADDR)]:=LSB(A) |
| SXBW | Sign eXtend Byte to Word | A:=SignExtend(LSB(A)) |
| CXBW | Copy-eXtend Byte to Word | HSB(A):=LSB(A) |
| ZXBW | Zero-eXtend Byte to Word | HSB(A):=0 |
| AXBW | All-eXtend Byte to Word | HSB(A):=0xFF |
| STWI | STore Word Indirect | [ADDR]:=A |
| ARV Word | Address Register from Value | ADDR:=Word |
| STSP | STore into Stack Pointer | SP:=A |
| PUSH | Push to stack | SP:=SP-2, [SP]:=A |
| SXWX | Sign eXtend Word to eXtended | (X:A):=SignExtend(LSB(A)) |
| CXWX | Copy-eXtend Word to eXtended | X:=A |
| ZXWX | Zero-eXtend Word to eXtended | X:=0 |
| AXWX | All-eXtend Word to eXtended | X:=0xFFFF |


|   | x0 | x1 | x2 | x3 | x4 | x5 | x6 | x7 | x8 | x9 | xA | xB | xC | xD | xE | xF |
| - | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| **0x** | LBR B0 | LBR B1 | LBR B2 | LBR B3 | LBR B4 | LBR B5 | LBR B6 | LBR B7 | LWR W0 | LWR W1 | LWR W2 | LWR W3
| **1x** | STBR B0 | STBR B1 | STBR B2 | STBR B3 | STBR B4 | STBR B5 | STBR B6 | STBR B7 | STWR W0 | STWR W1 | STWR W2 | STWR W3 
| **2x** | XBR B0 | XBR B1 | XBR B2 | XBR B3 | XBR B4 | XBR B5 | XBR B6 | XBR B7 | XWR W0 | XWR W1 | XWR W2 | XWR W3 
| **3x** | JIFLZ | JIFLNZ | JIFHZ | JIFHNZ | JIFZ | JIFNZ | JIFXZ | JIFXNZ
| **4x** | ADD | SUB |  AND | OR | XOR | JMP | CALL | RET | ARWR W0 | ARWR W1 | ARWR W2 | ARWR W3
| **5x** | ZERO | ALL | CPL | XHL | IN | OUT | | | ROL | ROR | ARA | XA | POP | PUSH
| **6x** | LBI | LBID Word | LBV Byte | | | | | | LWI | LWID Word | LWV Word | LSP 
| **7x** | STBI | STBID Word | NOP | | SXBW | CXBW | ZXBW | AXBW | STWI | STWID Word | ARV Word | STSP | SXWX | CXWX | ZXWX | AXWX
