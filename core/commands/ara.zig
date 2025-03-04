const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    vvm.registers.addr = vvm.registers.a.w[0].asWord();
}

test "Test" {
    const ara = Vvm.commands.ara;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = ara.opcode(); // ARA
    vvm.registers.a.w[0] = .initWord(0x9110);
    vvm.registers.addr = 0;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x9110, vvm.registers.addr);
}
