const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    const port: u8 = @truncate(vvm.registers.addr);
    vvm.env.vft.out(
        vvm.env.ptr,
        port,
        vvm.registers.a.b[0],
    );
}

test "Test" {
    const Env = struct {
        vvm: *Vvm,
        written_port: ?u8 = null,
        written_value: ?u8 = null,
        pub fn in(_: ?*anyopaque, _: u8) u8 {
            return 0;
        }
        pub fn out(ptr: ?*anyopaque, port: u8, value: u8) void {
            const self: *@This() = @alignCast(@ptrCast(ptr.?));
            self.written_port = port;
            self.written_value = value;
        }
    };

    const out = Command.collection.out;

    var vvm: Vvm = undefined;
    var env = Env{ .vvm = &vvm };
    vvm.init();
    vvm.env = .init(Env, &env);

    vvm.memory[0] = out.code(); // OUT
    vvm.registers.a.b[0] = 0x10;
    vvm.registers.addr = 0x1234;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x34, env.written_port);
    try std.testing.expectEqual(0x10, env.written_value);
}
