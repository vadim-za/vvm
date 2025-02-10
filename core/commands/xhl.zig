const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub fn handler(vvm: *Vvm) void {
    std.mem.swap(u8, &vvm.registers.a.b[0], &vvm.registers.a.b[1]);
}

test "Test" {
    const xhl = Vvm.commands.xhl;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = xhl.opcode(); // XHL
    vvm.registers.a.w[0] = .initWord(0x9110);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1091, vvm.registers.a.w[0].asWord());
}
