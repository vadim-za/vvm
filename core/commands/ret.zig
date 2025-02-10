const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.pc = vvm.popWord();
}

test "Test" {
    const ret = Vvm.commands.ret;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0x5678] = ret.opcode(); // RET
    vvm.memory[0xEFFE] = 0x34;
    vvm.memory[0xEFFF] = 0x12;
    vvm.registers.addr = 0xFFFF;
    vvm.registers.sp = 0xEFFE;
    vvm.registers.pc = 0x5678;
    vvm.step();

    try std.testing.expectEqual(0x1234, vvm.registers.pc);
    try std.testing.expectEqual(0xF000, vvm.registers.sp);
}
