const std = @import("std");

memory: Memory,
registers: Registers,

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
        w: u16,
        b: [2]u8,
    },
    x: u16,
};

pub fn run(self: *@This()) void {
    while (true)
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
