const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    vvm.registers.sp = vvm.registers.a.w[0].asWord();
}

test "Test" {
    const stsp = Vvm.commands.stsp;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = stsp.opcode(); // STSP
    vvm.registers.a.w[0] = .initWord(0x1231);
    vvm.registers.sp = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1231, vvm.registers.sp);
}
