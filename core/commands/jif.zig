const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(comptime command_opcode: u8) Command.Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u3 = command_opcode & 7;
            if (condition(vvm, index))
                vvm.registers.pc = vvm.registers.addr;
        }
    }.actualHandler;
}

fn condition(vvm: *Vvm, comptime condition_index: u3) bool {
    const bit0: u1 = condition_index & 1;
    const bit1: u1 = condition_index >> 1 & 1;
    const bit2: u1 = condition_index >> 2 & 1;

    const value = if (comptime bit2 != 0)
        vvm.registers.a.w[bit1].asWord()
    else
        vvm.registers.a.b[bit1];

    return if (comptime bit0 != 0)
        value != 0
    else
        value == 0;
}

test "Test" {
    const jif = Command.collection.jif;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = jif.opcodeVariant(0); // JIFLZ
    vvm.registers.addr = 0x1002;

    vvm.registers.a = .initDword(0xFFFF_FF00);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(0x1002, vvm.registers.pc); // taken

    vvm.registers.a = .initDword(0xFF);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(1, vvm.registers.pc); // not taken

    vvm.memory[0] = jif.opcodeVariant(1); // JIFLNZ
    vvm.registers.addr = 0x1002;

    vvm.registers.a = .initDword(0xFF);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(0x1002, vvm.registers.pc); // taken

    vvm.registers.a = .initDword(0xFFFF_FF00);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(1, vvm.registers.pc); // not taken

    vvm.memory[0] = jif.opcodeVariant(2); // JIFHZ
    vvm.registers.addr = 0x1002;

    vvm.registers.a = .initDword(0xFFFF_00FF);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(0x1002, vvm.registers.pc); // taken

    vvm.registers.a = .initDword(0xFF00);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(1, vvm.registers.pc); // not taken

    vvm.memory[0] = jif.opcodeVariant(3); // JIFHNZ
    vvm.registers.addr = 0x1002;

    vvm.registers.a = .initDword(0xFF00);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(0x1002, vvm.registers.pc); // taken

    vvm.registers.a = .initDword(0xFFFF_00FF);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(1, vvm.registers.pc); // not taken

    vvm.memory[0] = jif.opcodeVariant(4); // JIFZ
    vvm.registers.addr = 0x1002;

    vvm.registers.a = .initDword(0xFFFF_0000);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(0x1002, vvm.registers.pc); // taken

    vvm.registers.a = .initDword(0xFFFF);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(1, vvm.registers.pc); // not taken

    vvm.memory[0] = jif.opcodeVariant(5); // JIFNZ
    vvm.registers.addr = 0x1002;

    vvm.registers.a = .initDword(0xFFFF);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(0x1002, vvm.registers.pc); // taken

    vvm.registers.a = .initDword(0xFFFF_0000);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(1, vvm.registers.pc); // not taken

    vvm.memory[0] = jif.opcodeVariant(6); // JIFXZ
    vvm.registers.addr = 0x1002;

    vvm.registers.a = .initDword(0xFFFF);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(0x1002, vvm.registers.pc); // taken

    vvm.registers.a = .initDword(0xFFFF_0000);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(1, vvm.registers.pc); // not taken

    vvm.memory[0] = jif.opcodeVariant(7); // JIFXNZ
    vvm.registers.addr = 0x1002;

    vvm.registers.a = .initDword(0xFFFF_0000);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(0x1002, vvm.registers.pc); // taken

    vvm.registers.a = .initDword(0xFFFF);
    vvm.registers.pc = 0;
    vvm.step();
    try std.testing.expectEqual(1, vvm.registers.pc); // not taken
}
