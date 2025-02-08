pub const VvmCore = @import("VvmCore");

core: VvmCore,
env: Environment,

const Environment = struct {
    core: *VvmCore,
    written_port: ?u8 = null,
    written_value: ?u8 = null,
    offs: u8,
    pub fn in(ptr: ?*anyopaque, port: u8) u8 {
        const self: *@This() = @alignCast(@ptrCast(ptr.?));
        return port +% self.offs;
    }
    pub fn out(ptr: ?*anyopaque, port: u8, value: u8) void {
        const self: *@This() = @alignCast(@ptrCast(ptr.?));
        self.written_port = port;
        self.written_value = value;
    }
};

pub fn init(self: *@This()) void {
    self.env.core = &self.core;
    self.core.init();
    self.core.env = .init(Environment, &self.env);
}

test "Test" {
    var system: @This() = undefined;
    system.init();
}
