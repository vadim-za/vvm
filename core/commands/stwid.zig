const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    const displacement = vvm.fetchCommandWord();
    vvm.writeMemoryWord(
        vvm.registers.addr +% displacement,
        vvm.registers.a.w[0],
    );
}

test "Test" {
    const stwid = Command.collection.stwid;

    var vvm: Vvm = undefined;
    vvm.init();
    vvm.rom_addr = 0xF000;

    @memcpy(vvm.memory[0..3], &stwid.opcodeWithLiteral16(0xCFFA)); // STWID disp
    vvm.memory[0xEFFE] = 0;
    vvm.memory[0xEFFF] = 0;
    vvm.registers.a.w[0] = 0x1234;
    vvm.registers.addr = 0x2004;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x34, vvm.memory[0xEFFE]); // written
    try std.testing.expectEqual(0x12, vvm.memory[0xEFFF]); // written
    try std.testing.expectEqual(0x3, vvm.registers.pc);

    // Try to write across the ROM boundary
    @memcpy(vvm.memory[0..3], &stwid.opcodeWithLiteral16(0xCFFB)); // STBID disp
    vvm.memory[0xEFFF] = 0;
    vvm.memory[0xF000] = 0;
    vvm.registers.a.w[0] = 0x1234;
    vvm.registers.addr = 0x2004;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x34, vvm.memory[0xEFFF]); // not written
    try std.testing.expectEqual(0, vvm.memory[0xF000]); // not written
    try std.testing.expectEqual(0x3, vvm.registers.pc);
}
