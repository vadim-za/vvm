const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[1] = 0;
}

test "Test" {
    const zxwx = Command.collection.zxwx;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = zxwx.opcode(); // ZXWC
    vvm.registers.a.w[0] = 0x8F12;
    vvm.registers.a.w[1] = 0xFFFF;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x8F12, vvm.registers.a.dw);
}
