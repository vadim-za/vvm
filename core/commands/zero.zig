const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[0] = .initWord(0);
}

test "Test" {
    const zero = Vvm.commands.zero;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = zero.opcode(); // ZERO
    vvm.registers.a.w[0] = .initWord(0x9110);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0, vvm.registers.a.w[0].asWord());
}
