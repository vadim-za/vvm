const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    var sp = vvm.registers.sp;
    sp -%= 1;
    vvm.writeMemory(sp, vvm.registers.a.b[1]);
    sp -%= 1;
    vvm.writeMemory(sp, vvm.registers.a.b[0]);
    vvm.registers.sp = sp;
}

test "Test" {
    const push = Command.collection.push;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = push.code(); // PUSH
    vvm.registers.a.w[0] = 0x1234;
    vvm.memory[0x1000] = 0;
    vvm.memory[0x1001] = 0;
    vvm.registers.sp = 0x1002;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x34, vvm.memory[0x1000]);
    try std.testing.expectEqual(0x12, vvm.memory[0x1001]);
    try std.testing.expectEqual(0x1000, vvm.registers.sp);
}
