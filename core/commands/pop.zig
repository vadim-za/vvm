const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[0] = vvm.popWord();
}

test "Test" {
    const pop = Command.collection.pop;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = pop.opcode(); // POP
    vvm.registers.a.dw = 0;
    vvm.memory[0x1000] = 0x01;
    vvm.memory[0x1001] = 0x91;
    vvm.registers.sp = 0x1000;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x9101, vvm.registers.a.w[0]);
    try std.testing.expectEqual(0x1002, vvm.registers.sp);
}
