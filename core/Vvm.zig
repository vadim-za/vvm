const std = @import("std");
const Environment = @import("Environment.zig");

memory: Memory,
registers: Registers,
env: Environment,
running: bool,
rom_addr: u17, // lowest read-only address

pub fn init(self: *@This()) void {
    self.env = .default;
    self.running = false;
    self.rom_addr = 0x1_0000;
}

pub const Memory = [1 << 16]u8;

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

pub fn run(self: *@This()) void {
    self.running = true;
    while (self.running)
        self.step();
}

pub fn step(self: *@This()) void {
    const command_code = self.fetchCommandByte();
    self.dispatch(command_code);
}

// Fetch exactly one byte at PC and post-increment the PC
pub fn fetchCommandByte(self: *@This()) u8 {
    const byte = self.memory[self.registers.pc];
    self.registers.pc +%= 1;
    return byte;
}

pub fn writeMemory(self: *@This(), address: u16, value: u8) void {
    if (address < self.rom_addr)
        self.memory[address] = value;
}

// Given the just fetched command code, complete fetching the command and execute it.
fn dispatch(self: *@This(), command_code: u8) void {
    switch (command_code) {
        // We want the compiler to generate a dispatched jump instruction,
        // so use 'inline else'. Try achieving the same in C++ in a similarly
        // nice way, hehe (maybe some good optimizer can unwrap a function
        // pointer table to the same kind of code?)
        inline else => |code| (comptime commands[code])(self),
    }
}

const commands = @import("command_table.zig").table;

test "Test" {
    std.testing.refAllDecls(@This());
}
