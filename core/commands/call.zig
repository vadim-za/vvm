const std = @import("std");
const Vvm = @import("../Vvm.zig");

pub fn handler(vvm: *Vvm) void {
    vvm.pushWord(vvm.registers.pc);
    vvm.registers.pc = vvm.registers.addr;
}

test "Test" {
    const call = Vvm.commands.call;

    var vvm: Vvm = undefined;
    vvm.init();
    vvm.rom_addr = 0xF000;

    vvm.memory[0x1234] = call.opcode(); // CALL
    vvm.memory[0xEFFE] = 0;
    vvm.memory[0xEFFF] = 0;
    vvm.registers.addr = 0x5678;
    vvm.registers.sp = 0xF000;
    vvm.registers.pc = 0x1234;
    vvm.step();

    try std.testing.expectEqual(0x5678, vvm.registers.pc);
    try std.testing.expectEqual(0xEFFE, vvm.registers.sp);
    try std.testing.expectEqual(0x35, vvm.memory[0xEFFE]);
    try std.testing.expectEqual(0x12, vvm.memory[0xEFFF]);

    // CALL pushing address across the ROM boundary
    vvm.memory[0x1234] = call.opcode(); // CALL
    vvm.memory[0xEFFF] = 0;
    vvm.memory[0xF000] = 0;
    vvm.registers.addr = 0x5678;
    vvm.registers.sp = 0xF001;
    vvm.registers.pc = 0x1234;
    vvm.step();

    try std.testing.expectEqual(0x5678, vvm.registers.pc);
    try std.testing.expectEqual(0xEFFF, vvm.registers.sp);
    try std.testing.expectEqual(0x35, vvm.memory[0xEFFF]);
    try std.testing.expectEqual(0, vvm.memory[0xF000]); // not written
}
