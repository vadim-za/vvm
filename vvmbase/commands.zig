const Vvm = @import("Vvm.zig");

pub const table = prepareTable();

pub const Handler = fn (vvm: *Vvm) void;
const HandlerTable = [256]Handler;

fn prepareTable() HandlerTable {
    var tbl: HandlerTable = [1]Handler{commands.nop.handler} ** 256;

    for (0..8) |i| {
        tbl[0x00 + i] = commands.lbr.handler(i);
        // tbl[0x10 + i] = stbr(i);
        // tbl[0x20 + i] = xbr(i);
        // tbl[0x30 + i] = jif(i);
    }
    for (0..4) |i| {
        tbl[0x08 + i] = commands.lwr.handler(i);
        // tbl[0x18 + i] = stwr(i);
        // tbl[0x28 + i] = xwr(i);
        // tbl[0x48 + i] = arwr(i);
    }

    return tbl;
}

pub const Descriptor = struct {
    base: u8, // base command code
    count: u8, // variant count

    pub fn init(base_command_code: u8) @This() {
        return .{
            .base = base_command_code,
            .count = 1,
        };
    }

    pub fn initRange(base: u8, comptime count: u8) @This() {
        if (comptime count < 2)
            @compileError("Command range must contain at leats 2 variants");
        return .{
            .base = base,
            .count = count,
        };
    }
};

const commands = struct {
    pub const nop = @import("commands/nop.zig");
    pub const lbr = @import("commands/lbr.zig");
    pub const lwr = @import("commands/lwr.zig");
    // const stbr = @import("commands/stbr.zig").handler;
    // const stwr = @import("commands/stwr.zig").handler;
    // const xbr = @import("commands/xbr.zig").handler;
    // const xwr = @import("commands/xwr.zig").handler;
    // const jif = @import("commands/jif.zig").handler;
    // const arwr = @import("commands/arwr.zig").handler;
};
