const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.b[1] = 0;
}

test "Test" {
    const zxbw = Vvm.commands.zxbw;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = zxbw.opcode(); // ZXBW
    vvm.registers.a.b[0] = 0x8F;
    vvm.registers.a.b[1] = 0xFF;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x008F, vvm.registers.a.w[0].asWord());
}
