const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[1] = .initWord(0xFFFF);
}

test "Test" {
    const axwx = Vvm.commands.axwx;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = axwx.opcode(); // AXWX
    vvm.registers.a.w[0] = .initWord(0x8F12);
    vvm.registers.a.w[1] = .initWord(0);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xFFFF8F12, vvm.registers.a.asDword());
}
