const std = @import("std");
const System = @import("../System.zig");

pub fn run() void {
    var system: System = undefined;
    system.init();

    const code = [_]u8{
        0x7A, 0x01, 0x00, // ARV 0x0001
        0x62, 0x41, // LBV 'A'
        0x55, // OUT
        0x50, 0x5A, 0x55, // ZERO ; ARA ; OUT
    };

    const core = &system.core;
    @memcpy(core.memory[0..code.len], &code);
    core.registers.pc = 0;
    if (!system.run(1000))
        std.debug.print("\nLooped\n", .{});
}
