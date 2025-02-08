const VvmCore = @import("VvmCore");
const System = @import("System.zig");

system: *System, // manually set by the owning System

// ------------------ "virtual" methods

pub fn envIn(ptr: ?*anyopaque, port: u8) u8 {
    _ = ptr; // autofix
    _ = port; // autofix
    return 0;
}

pub fn envOut(ptr: ?*anyopaque, port: u8, value: u8) void {
    const self: *@This() = @alignCast(@ptrCast(ptr.?));
    if (port == 0) {
        if (value & 1 == 0)
            self.system.core.running = false;
    }
}
