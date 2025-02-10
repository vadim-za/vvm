const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[1] = vvm.registers.a.w[0];
}

test "Test" {
    const cxwx = Vvm.commands.cxwx;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = cxwx.opcode(); // CXWX
    vvm.registers.a.w[0] = .initWord(0x8F12);
    vvm.registers.a.w[1] = .initWord(0);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x8F128F12, vvm.registers.a.asDword());
}
