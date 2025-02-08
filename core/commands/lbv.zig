const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    const byte = vvm.fetchCommandByte();
    vvm.registers.a.b[0] = byte;
}

test "Test" {
    const lbv = Command.collection.lbv;

    var vvm: Vvm = undefined;
    vvm.init();

    @memcpy(vvm.memory[0..2], &lbv.codeWithLiteral8(0x10)); // LBV 0x10
    vvm.registers.a.w[0] = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x10, vvm.registers.a.b[0]);
    try std.testing.expectEqual(0x2, vvm.registers.pc);
}
