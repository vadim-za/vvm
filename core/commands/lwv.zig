const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    const lsb = vvm.fetchCommandByte();
    const hsb = vvm.fetchCommandByte();
    const word: u16 = (@as(u16, hsb) << 8) + lsb;
    vvm.registers.a.w[0] = word;
}

test "Test" {
    const lwv = Command.collection.lwv;

    var vvm: Vvm = undefined;
    vvm.init();

    @memcpy(vvm.memory[0..3], &lwv.codeWithLiteral16(0x1234)); // LWV 0x1234

    // use the occasion to test lwv.codeWithLiteral16
    try std.testing.expectEqual(0x34, vvm.memory[1]);
    try std.testing.expectEqual(0x12, vvm.memory[2]);

    vvm.registers.a.w[0] = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1234, vvm.registers.a.w[0]);
    try std.testing.expectEqual(0x3, vvm.registers.pc);
}
