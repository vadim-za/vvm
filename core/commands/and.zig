const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[0] = .initWord(
        vvm.registers.a.w[0].asWord() & vvm.registers.a.w[1].asWord(),
    );
}

test "Test" {
    const @"and" = Vvm.commands.@"and";

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = @"and".opcode(); // AND
    vvm.registers.a.w[0] = .initWord(0x9112);
    vvm.registers.a.w[1] = .initWord(0x800E);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x8002, vvm.registers.a.w[0].asWord());
}
