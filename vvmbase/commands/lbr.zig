const Vvm = @import("../Vvm.zig");
const Handler = @import("../commands.zig").Handler;

pub fn handler(comptime command_code: u8) Handler {
    return struct {
        fn actualHandler(vvm: *Vvm) void {
            const index: u4 = command_code & 15;
            vvm.registers.a.b[0] = vvm.registers.gp.b[index];
        }
    }.actualHandler;
}
