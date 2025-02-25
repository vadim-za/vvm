const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[0] = .initWord(
        ~vvm.registers.a.w[0].asWord(),
    );
}

test "Test" {
    const cpl = Vvm.commands.cpl;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = cpl.opcode(); // CPL
    vvm.registers.a.w[0] = .initWord(0x9110);
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x9110 ^ 0xFFFF, vvm.registers.a.w[0].asWord());
}
