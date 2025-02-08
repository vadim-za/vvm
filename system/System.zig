const std = @import("std");
const VvmCore = @import("VvmCore");
const Environment = @import("Environment.zig");

core: VvmCore,
env: Environment,

pub fn init(self: *@This()) void {
    self.env.system = self;
    self.core.init();
    self.core.env = .init(Environment, &self.env);
}

test "Test" {
    var system: @This() = undefined;
    system.init();

    const core = &system.core;
    core.memory[0] = 0x50; // ZERO
    core.memory[1] = 0x5A; // ARA
    core.memory[2] = 0x55; // OUT
    core.registers.pc = 0;
    //@breakpoint();
    core.run();

    try std.testing.expectEqual(3, core.registers.pc);
}
