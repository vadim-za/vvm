const std = @import("std");
const Vvm = @import("../Vvm.zig");
const Command = @import("../Command.zig");

pub fn handler(vvm: *Vvm) void {
    const port: u8 = @truncate(vvm.registers.addr);
    vvm.registers.a.b[0] = vvm.ienv.vft.in(vvm.ienv.ptr, port);
}

test "Test" {
    const Env = struct {
        vvm: *Vvm,
        offs: u8,
        pub fn envIn(ptr: ?*anyopaque, port: u8) u8 {
            const self: *@This() = @alignCast(@ptrCast(ptr.?));
            return port +% self.offs;
        }
        pub fn envOut(_: ?*anyopaque, _: u8, _: u8) void {}
    };

    const in = Vvm.commands.in;

    var vvm: Vvm = undefined;
    var env = Env{ .vvm = &vvm, .offs = 0xF0 };
    vvm.init();
    vvm.ienv = .init(Env, &env);

    vvm.memory[0] = in.opcode(); // IN
    vvm.registers.a = .initDword(0);
    vvm.registers.addr = 0x1234;
    vvm.registers.pc = 0;
    vvm.step();

    try std.testing.expectEqual(0x24, vvm.registers.a.b[0]);
}
