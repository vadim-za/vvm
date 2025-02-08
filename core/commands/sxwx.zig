const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    const w: i16 = @bitCast(vvm.registers.a.w[0]);
    const dw: i32 = w;
    vvm.registers.a.dw = @bitCast(dw);
}

test "Test" {
    const sxwx = Command.collection.sxwx;

    var vvm: Vvm = undefined;
    vvm.init();

    // Positive values, no sign to extend
    vvm.memory[0] = sxwx.opcode(); // SXWX
    vvm.registers.a.w[0] = 0x7F12;
    vvm.registers.a.w[1] = 0xFFFF;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x7F12, vvm.registers.a.dw);

    // Negative values, sign need to be extended
    vvm.memory[0] = sxwx.opcode(); // SXWX
    vvm.registers.a.w[0] = 0x8012;
    vvm.registers.a.w[1] = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xFFFF8012, vvm.registers.a.dw);
}
