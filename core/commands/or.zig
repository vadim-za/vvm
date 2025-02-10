const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[0] = .initWord(
        vvm.registers.a.w[0].asWord() | vvm.registers.a.w[1].asWord(),
    );
}

test "Test" {
    const @"or" = Vvm.commands.@"or";

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = @"or".opcode(); // OR
    vvm.registers.a.w[0] = .initWord(0x9112);
    vvm.registers.a.w[1] = .initWord(0xC00E);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xD11E, vvm.registers.a.w[0].asWord());
}
