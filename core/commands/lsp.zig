const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.registers.a.w[0] = vvm.registers.sp;
}

test "Test" {
    const lsp = Command.collection.lsp;

    var vvm: Vvm = undefined;
    vvm.init();

    vvm.memory[0] = lsp.code(); // LSP
    vvm.registers.a.dw = 0;
    vvm.registers.sp = 0x1231;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x1231, vvm.registers.a.w[0]);
}
