# Basic Architecture and Instruction Set

Little-endian architecture, 16-bit address space

| Entity kind | Instances |
| ----------- | --------- |
| Byte registers | B0, B1, B2, B3, B4, B5, B6, B7 |
| Word (2-byte) registers | W0, W1, W2, W3 (where W0=B1:B0, W1=B3:B2, W2=B5:B4, W3=B7:B6) |
| Additional word registers | PC (program counter), A (accumulator), X (accumulator eXtension), ADDR (address register) |
The low and high bytes of the accumulator may be also referred to as `LoB(A)`/`HiB(A)` and/or `L` and `H`

| Command | Deciphering | Description |
| ------- | ----------- | ----------- |
| LBR Bn | Load from Byte Register | LoB(A):=Bn |
| LWR Wn | Load from Word Register | A:=Wn |
| STBR Bn | STore to Byte Register | Bn:=LoB(A) |
| STWR Wn | STore to Word Register | Wn:=A |
| XBR Bn | eXchange Byte Register | LoB(A)<->Bn |
| XWR Wn | eXchange Word Register | A<->Wn |
| JIF cond | Jump IF condition | if(cond) PC:=ADDR |
| | LZ: Low byte is Zero | LoB(A)==0 |
| | LNZ: Low byte is Not Zero | LoB(A)!=0 |
| | HZ: High byte is Zero | HiB(A)==0 |
| | HNZ: High byte is Not Zero | HiB(A)!=0 |
| | Z: accumulator is Zero | A==0 |
| | NZ: accumulator is Not Zero | A!=0 |
| | XZ: accumulator eXtension is Zero | X==0 |
| | XNZ: accumulator eXtension is Not Zero | X!=0 |
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
| XHL | eXchange accumulator's high and low bytes | HiB(A)<->LoB(A) |
| IN | Input: read from port | LoB(A):=Port[LoB(ADDR)] |
| OUT | Output: write into port | Port[LoB(ADDR)]:=LoB(A) |
| ROL | ROtate extended accumulator Left | (X:A):=ROL(X:A) |
| ROR | ROtate extended accumulator Right | (X:A):=ROR(X:A) |
| ARA | Address Register from Accumulator | ADDR:=A |
| XA | eXchange the accumulators | X<->A |
| POP | Pop from stack | A:=[SP], SP:=SP+2 |
| PUSH | Push to stack | SP:=SP-2, [SP]:=A |
| LBI | Load Byte Indirect | LoB(A):=[ADDR] |
| LBID Word | Load Byte Indirect Displaced | LoB(A):=[ADDR+Word] |
| LBV Byte | Load Byte Value | LoB(A):=Byte |
| LWI | Load Word Indirect | A:=[ADDR] |
| LWID Word | Load Word Indirect Displaced | A:=[ADDR+Word] |
| LWV Word | Load Word Value | A:=Word |
| LSP | Load Stack Pointer | A:=SP |
| STBI | STore Byte Indirect | [ADDR]:=LoB(A) |
| STBID Word | STore Byte Indirect Displaced | [ADDR+Word]:=LoB(A) |
| NOP | No-operation | Do nothing |
| SXBW | Sign eXtend Byte to Word | A:=SignExtend(LoB(A)) |
| CXBW | Copy-eXtend Byte to Word | HiB(A):=LoB(A) |
| ZXBW | Zero-eXtend Byte to Word | HiB(A):=0 |
| AXBW | All-eXtend Byte to Word | HiB(A):=0xFF |
| STWI | STore Word Indirect | [ADDR]:=A |
| STWID Word | STore Word Indirect Displaced | [ADDR+Word]:=A |
| ARV Word | Address Register from Value | ADDR:=Word |
| STSP | STore into Stack Pointer | SP:=A |
| SXWX | Sign eXtend Word to eXtended | (X:A):=SignExtend(LSB(A)) |
| CXWX | Copy-eXtend Word to eXtended | X:=A |
| ZXWX | Zero-eXtend Word to eXtended | X:=0 |
| AXWX | All-eXtend Word to eXtended | X:=0xFFFF |


|   | x0 | x1 | x2 | x3 | x4 | x5 | x6 | x7 | x8 | x9 | xA | xB | xC | xD | xE | xF |
| - | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| **0x** | LBR B0 | LBR B1 | LBR B2 | LBR B3 | LBR B4 | LBR B5 | LBR B6 | LBR B7 | LWR W0 | LWR W1 | LWR W2 | LWR W3
| **1x** | STBR B0 | STBR B1 | STBR B2 | STBR B3 | STBR B4 | STBR B5 | STBR B6 | STBR B7 | STWR W0 | STWR W1 | STWR W2 | STWR W3 
| **2x** | XBR B0 | XBR B1 | XBR B2 | XBR B3 | XBR B4 | XBR B5 | XBR B6 | XBR B7 | XWR W0 | XWR W1 | XWR W2 | XWR W3 
| **3x** | JIF LZ | JIF LNZ | JIF HZ | JIF HNZ | JIF Z | JIF NZ | JIF XZ | JIF XNZ
| **4x** | ADD | SUB |  AND | OR | XOR | JMP | CALL | RET | ARWR W0 | ARWR W1 | ARWR W2 | ARWR W3
| **5x** | ZERO | ALL | CPL | XHL | IN | OUT | | | ROL | ROR | ARA | XA | POP | PUSH
| **6x** | LBI | LBID Word | LBV Byte | | | | | | LWI | LWID Word | LWV Word | LSP 
| **7x** | STBI | STBID Word | NOP | | SXBW | CXBW | ZXBW | AXBW | STWI | STWID Word | ARV Word | STSP | SXWX | CXWX | ZXWX | AXWX

Note: commands with a *Byte* operand have the byte following the command opcode.
Commands with a *Word* operand have the word's bytes (little-endian order) following the command opcode.
Examples:

| Mnemonic | Machine Code Bytes (Hex) |
| -------- | ------------------------ |
| LBI | 60 |
| LBV 1C | 62 1C |
| LBID 1C2E | 61 2E 1C |

I/O functionality depends on the system's *environment* and is documented separately.