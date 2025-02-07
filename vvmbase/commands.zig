const Vvm = @import("Vvm.zig");

pub const table = prepareTable();
pub const Handler = fn (vvm: *Vvm) void;

const HandlerTable = [256]Handler;

fn prepareTable() HandlerTable {
    var tbl: HandlerTable = [1]Handler{nop} ** 256;

    for (0..7) |i| {
        tbl[0x00 + i] = lbr(i);
        // tbl[0x10 + i] = stbr(i);
        // tbl[0x20 + i] = xbr(i);
        // tbl[0x30 + i] = jif(i);
    }
    for (0..3) |i| {
        _ = i;
        // tbl[0x08 + i] = lwr(i);
        // tbl[0x18 + i] = stwr(i);
        // tbl[0x28 + i] = xwr(i);
        // tbl[0x48 + i] = arwr(i);
    }

    return tbl;
}

const nop = @import("commands/nop.zig").handler;
const lbr = @import("commands/lbr.zig").handler;
// const lwr = @import("commands/lwr.zig").handler;
// const stbr = @import("commands/stbr.zig").handler;
// const stwr = @import("commands/stwr.zig").handler;
// const xbr = @import("commands/xbr.zig").handler;
// const xwr = @import("commands/xwr.zig").handler;
// const jif = @import("commands/jif.zig").handler;
// const arwr = @import("commands/arwr.zig").handler;
