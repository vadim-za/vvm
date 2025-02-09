const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.b[1] = vvm.registers.a.b[0];
}

test "Test" {
    const cxbw = Command.collection.cxbw;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = cxbw.opcode(); // CXBW
    vvm.registers.a.b[0] = 0x8F;
    vvm.registers.a.b[1] = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x8F8F, vvm.registers.a.w[0].asWord());
}
