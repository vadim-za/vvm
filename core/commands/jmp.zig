const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.pc = vvm.registers.addr;
}

test "Test" {
    const jmp = Command.collection.jmp;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = jmp.opcode(); // JMP
    vvm.registers.addr = 0x1002;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1002, vvm.registers.pc);
}
