const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    const b: i8 = @bitCast(vvm.registers.a.b[0]);
    const w: i16 = b;
    vvm.registers.a.w[0] = .initWord(@bitCast(w));
}

test "Test" {
    const sxbw = Vvm.commands.sxbw;

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
