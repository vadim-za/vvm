const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.writeMemory(vvm.registers.addr, vvm.registers.a.b[0]);
}

test "Test" {
    const stbi = Command.collection.stbi;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = stbi.code(); // STBI
    vvm.memory[0x1002] = 0;
    vvm.registers.a.b[0] = 0x10;
    vvm.registers.addr = 0x1002;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x10, vvm.memory[0x1002]);
}
