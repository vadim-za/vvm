const Vvm = @import("../Vvm.zig");
const commands = @import("../commands.zig");

pub const descriptor = commands.Descriptor.init(0x5A);

pub fn handler(vvm: *Vvm) void {
    _ = vvm;
}
