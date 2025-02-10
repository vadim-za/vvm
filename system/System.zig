const std = @import("std");
const VvmCore = @import("VvmCore");
const Environment = @import("Environment.zig");

core: VvmCore,
env: Environment,

pub fn init(self: *@This()) void {
    self.env.init(self);
    self.core.init();
    self.core.ienv = .init(Environment, &self.env);
}

pub fn run(self: *@This(), max_steps: ?usize) bool {
    self.env.cpu_mode = 1;

    var remaining_steps = max_steps;
    while (true) {
        if (self.env.cpu_mode == 0)
            return true; // successfully finished

        if (remaining_steps) |*steps| {
            if (steps.* == 0)
                return false; // seems to loop indefinitely
            steps.* -|= 1;
        }

        self.core.step();
    }
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

pub fn main() void {
    var system: @This() = undefined;
    system.init();

    //@import("examples/print_a.zig").run();
    @import("examples/out_string.zig").run();
    //@import("examples/print_input.zig").run();
    //@import("examples/realtime_input.zig").run();
    //@import("examples/print_delayed.zig").run();
}
