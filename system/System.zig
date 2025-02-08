const std = @import("std");
const VvmCore = @import("VvmCore");
const Environment = @import("Environment.zig");

core: VvmCore,
env: Environment,

pub fn init(self: *@This()) void {
    self.env.init(self);
    self.core.init();
    self.core.env = .init(Environment, &self.env);
}

fn run(self: *@This(), max_steps: usize) bool {
    self.env.running = true;
    for (0..max_steps) |_| {
        if (!self.env.running)
            return true; // successfully finished
        self.core.step();
    }
    return false; // seems to loop indefinitely
}

test "Test" {
    var system: @This() = undefined;
    system.init();

    const core = &system.core;
    core.memory[0] = 0x50; // ZERO
    core.memory[1] = 0x5A; // ARA
    core.memory[2] = 0x55; // OUT
    core.registers.pc = 0;
    try std.testing.expect(system.run(10));
    try std.testing.expectEqual(3, core.registers.pc);
}
