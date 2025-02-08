const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    std.mem.swap(u16, &vvm.registers.a.w[0], &vvm.registers.a.w[1]);
}

test "Test" {
    const xa = Command.collection.xa;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = xa.opcode(); // XA
    vvm.registers.a.w[0] = 0xFED9;
    vvm.registers.a.w[1] = 0xBA98;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0xBA98, vvm.registers.a.w[0]);
    try std.testing.expectEqual(0xFED9, vvm.registers.a.w[1]);
}
