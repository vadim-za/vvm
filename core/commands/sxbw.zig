const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");
const bid = @import("../bid.zig");

pub fn handler(vvm: *Vvm) void {
    const ib: i8 = @bitCast(vvm.registers.a.b[0]);
    const iw: i16 = ib;
    const w: u16 = @bitCast(iw);
    vvm.registers.a.b[1] = bid.hiHalf(w);
}

test "Test" {
    const sxbw = Command.collection.sxbw;

    var vvm: Vvm = undefined;
    vvm.init();

    // Positive values, no sign to extend
    vvm.memory[0] = sxbw.opcode(); // SXBW
    vvm.registers.a.b[0] = 0x7F;
    vvm.registers.a.b[1] = 0xFF;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x7F, vvm.registers.a.w[0].asWord());

    // Negative values, sign need to be extended
    vvm.memory[0] = sxbw.opcode(); // SXBW
    vvm.registers.a.b[0] = 0x80;
    vvm.registers.a.b[1] = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xFF80, vvm.registers.a.w[0].asWord());
}
