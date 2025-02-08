const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    const displacement = vvm.fetchCommandWord();
    vvm.registers.a.b[0] = vvm.memory[vvm.registers.addr +% displacement];
}

test "Test" {
    const lbid = Command.collection.lbid;

    var vvm: Vvm = undefined;
    vvm.init();

    @memcpy(vvm.memory[0..3], &lbid.codeWithLiteral16(0xEFFE)); // LBID disp
    vvm.memory[0x1002] = 0x10;
    vvm.registers.a.dw = 0;
    vvm.registers.addr = 0x2004;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x10, vvm.registers.a.b[0]);
}
