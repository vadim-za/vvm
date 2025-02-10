// This is the core of the virtual machine, consisting of the processor
// and 64K of actual memory (not just address space).
// This core is supposed to be augmented by an "environment", which
// is expected to provide access to the "rest of the system" by connecting
// the core's ports to the "actual hardware".
// An arbitrarily large range of memory at the end of the address space
// can be declared read-only by setting the 'rom_addr' field.

const std = @import("std");
const Registers = @import("Registers.zig");
const IEnv = @import("IEnv.zig");

// A struct containing all commands as its fields (of Command type each).
pub const commands = @import("command_collection.zig").collectAll();

// This could get useful as utility
pub const bid = @import("bid.zig");

// All these fields may be initialized/manipulated by the user.
// It is however recommended to call init() before accessing any of these.
memory: Memory,
registers: Registers,
ienv: IEnv, // connection to the rest of the system
rom_addr: u17, // memory is read-only at rom_addr and above

pub const Memory = [1 << 16]u8; // 64K of RAM
pub const WordRegister = Registers.WordRegister;

// The user is supposed to start with an uninitialized struct and then call
// init(). Afterwards, the user may override the 'env' and 'rom_addr' fields.
pub fn init(self: *@This()) void {
    self.ienv = .default; // not connected to anything
    self.rom_addr = 0x1_0000; // the entire memory is read/write
}

// Execute a single command at PC, incrementing PC by the command size.
// PC is incremented prior to the command execution.
// We don't provide a run() method here, since executing the code
// indefinitely would typically need to provide an option to stop
// the code execution, which is supposed to be done by accessing the
// environment through the ports. So the run() functionality
// would need to be implemented in the context of the respective
// larger system.
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

// Fetch two command bytes (LoB, then HiB) and return them as a single word
pub fn fetchCommandWord(self: *@This()) u16 {
    const lob = self.fetchCommandByte();
    const hib = self.fetchCommandByte();
    return bid.combine(hib, lob);
}

// Write a byte to memory. Attempts to write to read-only memory range are blocked.
pub fn writeMemory(self: *@This(), address: u16, value: u8) void {
    if (address < self.rom_addr)
        self.memory[address] = value;
}

// Convenience helper function to read a 2-byte word from memory.
pub fn readMemoryWord(self: *@This(), address: u16) u16 {
    const lob = self.memory[address];
    const hib = self.memory[address +% 1];
    return bid.combine(hib, lob);
}

// Convenience helper function to write a 2-byte word to memory.
// Attempts to write to read-only memory range are blocked on per-byte level.
pub fn writeMemoryWord(self: *@This(), address: u16, value: u16) void {
    const lob = bid.loHalf(value);
    const hib = bid.hiHalf(value);
    self.writeMemory(address, lob);
    self.writeMemory(address +% 1, hib);
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
        inline else => |opcode| @call(
            .always_inline,
            comptime opcode_table[opcode],
            .{self},
        ),
    }
}

const opcode_table = @import("opcode_table.zig").table;

test "Test" {
    // Ensure the other tests are performed
    std.testing.refAllDecls(@This());
}
