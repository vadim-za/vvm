const std = @import("std");
const VvmCore = @import("VvmCore");
const System = @import("System.zig");
const Timer = @import("timer.zig").SystemTimer;
const builtin = @import("builtin");
const keyboard_support = switch (builtin.os.tag) {
    .windows => @import("keyboard_support/windows.zig"), // realtime input support
    else => @import("keyboard_support/default.zig"), // no realtime input support
};

system: *System, // manually set by the owning System
cpu_mode: u8 = 0,
output: std.io.AnyWriter,

timer: Timer,

// System is not fully initialized yet at the time of the call
pub fn init(self: *@This(), system: *System) void {
    const stdout = std.io.getStdOut();
    _ = stdout.getOrEnableAnsiEscapeSupport();

    self.* = .{
        .system = system,
        .output = stdout.writer().any(),
        .timer = .init(),
    };
}

fn readKey(self: *@This()) u8 {
    _ = self;
    return keyboard_support.readKey();
}

// ------------------ "virtual" methods

pub fn envIn(ptr: ?*anyopaque, port: u8) u8 {
    const self: *@This() = @alignCast(@ptrCast(ptr.?));
    return switch (port) {
        1 => self.readKey(),
        2 => keyboard_support.getInputMode(),
        else => 0xFF,
    };
}

pub fn envOut(ptr: ?*anyopaque, port: u8, value: u8) void {
    const self: *@This() = @alignCast(@ptrCast(ptr.?));
    switch (port) {
        0 => {
            self.cpu_mode = value;
            if (value == 2)
                self.timer.wait();
        },
        1 => {
            self.output.writeByte(value) catch {};
        },
        2 => {
            keyboard_support.setInputMode(value);
        },
        3 => {
            self.timer.timeout_4ms = value;
        },
        else => {},
    }
}
