// This is the core of the virtual machine, consisting of the processor
// and 64K of actual memory (not just address space).
// This core is supposed to be augmented by an "Environment", which
// is expected to provide access to the "rest of the system" by connecting
// the core's ports to the "actual hardware".
// An arbitrarily large range of memory at the end of the address space
// can be declare read-only.

const std = @import("std");
const Environment = @import("Environment.zig");

// All these fields may be initialized/manipulated by the user.
// It is however recommended to call init() before accessing any of these.
memory: Memory,
registers: Registers,
env: Environment, // connection to the rest of the system
rom_addr: u17, // memory is read-only at rom_addr and above

// The user is supposed to start with an uninitialized struct and then call
// init(). Afterwards, the user may override the 'env' and 'rom_addr' fields.
pub fn init(self: *@This()) void {
    self.env = .default;
    self.rom_addr = 0x1_0000;
}

pub const Memory = [1 << 16]u8; // 64K of RAM

// See the architectural documentation for details
pub const Registers = struct {
    gp: extern union {
        b: [8]u8,
        w: [4]u16,
    },
    pc: u16,
    sp: u16,
    addr: u16,
    a: extern union {
        dw: u32, // (x:a)
        w: [2]u16, // w[0]=a, w[1]=x
        b: [2]u8,
    },
};

// Execute a single command at PC, incrementing PC by the command size.
// PC is incremented prior to the command execution.
pub fn step(self: *@This()) void {
    const command_opcode = self.fetchCommandByte();
    self.dispatch(command_opcode);
}

// Fetch exactly one byte at PC and post-increment the PC
pub fn fetchCommandByte(self: *@This()) u8 {
    const byte = self.memory[self.registers.pc];
    self.registers.pc +%= 1;
    return byte;
}

// Fetch two command bytes (LSB, then MSB) and return them as a single word
pub fn fetchCommandWord(self: *@This()) u16 {
    const lsb = self.fetchCommandByte();
    const msb = self.fetchCommandByte();
    return lsb + (@as(u16, msb) << 8);
}

// Write a byte to memory. Attempts to write to read-only memory range are blocked.
pub fn writeMemory(self: *@This(), address: u16, value: u8) void {
    if (address < self.rom_addr)
        self.memory[address] = value;
}

// Convenience helper function to read a 2-byte word from memory.
pub fn readMemoryWord(self: *@This(), address: u16) u16 {
    const lsb = self.memory[address];
    const msb = self.memory[address +% 1];
    return lsb + (@as(u16, msb) << 8);
}

// Convenience helper function to write a 2-byte word to memory.
// Attempts to write to read-only memory range are blocked on per-byte level.
pub fn writeMemoryWord(self: *@This(), address: u16, value: u16) void {
    const lsb: u8 = @intCast(value & 0xFF);
    const msb: u8 = @intCast(value >> 8);
    self.writeMemory(address, lsb);
    self.writeMemory(address +% 1, msb);
}

// Push a word to the stack. SP doesn't need to be even-aligned.
// Attempts to write to read-only memory range are blocked on per-byte level.
pub fn pushWord(self: *@This(), value: u16) void {
    self.registers.sp -%= 2;
    self.writeMemoryWord(self.registers.sp, value);
}

// Pop a word from the stack. SP doesn't need to be even-aligned.
pub fn popWord(self: *@This()) u16 {
    const result = self.readMemoryWord(self.registers.sp);
    self.registers.sp +%= 2;
    return result;
}

// Given the just fetched command opcode, complete fetching the command and execute it.
fn dispatch(self: *@This(), command_opcode: u8) void {
    switch (command_opcode) {
        // We want the compiler to generate a dispatched jump instruction,
        // so use 'inline else'. Try achieving the same in C++ in a similarly
        // nice way, hehe (maybe some good optimizer can unwrap a function
        // pointer table to the same kind of code?)
        inline else => |opcode| (comptime commands[opcode])(self),
    }
}

// The opcode table
const commands = @import("command_table.zig").table;

test "Test" {
    // Ensure the other tests are performed
    std.testing.refAllDecls(@This());
}
