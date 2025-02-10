const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm, byte: u8) void {
    vvm.registers.a.b[0] = byte;
}

test "Test" {
    const lbv = Vvm.commands.lbv;

    var vvm: Vvm = undefined;
    vvm.init();

    @memcpy(vvm.memory[0..2], &lbv.opcodeWithLiteral8(0x10)); // LBV 0x10
    vvm.registers.a.w[0] = .initWord(0);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x10, vvm.registers.a.b[0]);
    try std.testing.expectEqual(0x2, vvm.registers.pc);
}
