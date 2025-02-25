const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.b[0] = vvm.memory[vvm.registers.addr];
}

test "Test" {
    const lbi = Vvm.commands.lbi;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = lbi.opcode(); // LBI
    vvm.memory[0x1002] = 0x10;
    vvm.registers.a = .initDword(0);
    vvm.registers.addr = 0x1002;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x10, vvm.registers.a.b[0]);
}
