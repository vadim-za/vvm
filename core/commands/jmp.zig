const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub const variant_type = .none;

pub fn handler(vvm: *Vvm) void {
    vvm.registers.pc = vvm.registers.addr;
}

test "Test" {
    const jmp = Vvm.commands.jmp;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = jmp.opcode(); // JMP
    vvm.registers.addr = 0x1002;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1002, vvm.registers.pc);
}
