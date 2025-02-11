// The 'commands' table at the end of this file is the original
// source from which the main opcode table in 'opcode_table.zig'
// is built (at comptime).

const Command = @import("Command.zig");

pub fn toCommand(entry: Entry) Command {
    return .{
        .name = entry[0],
        .base_opcode = entry[1],
        .variant_count = entry[2],
        .impl = entry[3],
    };
}

pub const Entry = struct {
    [:0]const u8, // mnemonic
    u8, // base opcode
    u8, // variant count
    type, // impl namespace
};

pub const commands = [_]Entry{
    // zig fmt: off
    .{ "lbr",  0x00, 8, @import("commands/lbr.zig") },
    .{ "lwr",  0x08, 4, @import("commands/lwr.zig") },
    .{ "stbr", 0x10, 8, @import("commands/stbr.zig") },
    .{ "stwr", 0x18, 4, @import("commands/stwr.zig") },
    .{ "xbr",  0x20, 8, @import("commands/xbr.zig") },
    .{ "xwr",  0x28, 4, @import("commands/xwr.zig") },
    .{ "jif",  0x30, 8, @import("commands/jif.zig") },
    .{ "add",  0x40, 1, @import("commands/add.zig") },
    .{ "sub",  0x41, 1, @import("commands/sub.zig") },
    .{ "and",  0x42, 1, @import("commands/and.zig") },
    .{ "or",   0x43, 1, @import("commands/or.zig") },
    .{ "xor",  0x44, 1, @import("commands/xor.zig") },
    .{ "jmp",  0x45, 1, @import("commands/jmp.zig") },
    .{ "call", 0x46, 1, @import("commands/call.zig") },
    .{ "ret",  0x47, 1, @import("commands/ret.zig") },
    .{ "arwr", 0x48, 4, @import("commands/arwr.zig") },
    .{ "zero", 0x50, 1, @import("commands/zero.zig") },
    .{ "all",  0x51, 1, @import("commands/all.zig") },
    .{ "cpl",  0x52, 1, @import("commands/cpl.zig") },
    .{ "xhl",  0x53, 1, @import("commands/xhl.zig") },
    .{ "in",   0x54, 1, @import("commands/in.zig") },
    .{ "out",  0x55, 1, @import("commands/out.zig") },
    .{ "rol",  0x58, 1, @import("commands/rol.zig") },
    .{ "ror",  0x59, 1, @import("commands/ror.zig") },
    .{ "ara",  0x5A, 1, @import("commands/ara.zig") },
    .{ "xa",   0x5B, 1, @import("commands/xa.zig") },
    .{ "pop",  0x5C, 1, @import("commands/pop.zig") },
    .{ "push", 0x5D, 1, @import("commands/push.zig") },
    .{ "lbi",  0x60, 1, @import("commands/lbi.zig") },
    .{ "lbid", 0x61, 1, @import("commands/lbid.zig") },
    .{ "lbv",  0x62, 1, @import("commands/lbv.zig") },
    .{ "lwi",  0x68, 1, @import("commands/lwi.zig") },
    .{ "lwid", 0x69, 1, @import("commands/lwid.zig") },
    .{ "lwv",  0x6A, 1, @import("commands/lwv.zig") },
    .{ "lsp",  0x6B, 1, @import("commands/lsp.zig") },
    .{ "stbi", 0x70, 1, @import("commands/stbi.zig") },
    .{ "stbid",0x71, 1, @import("commands/stbid.zig") },
    .{ "nop",  0x72, 1, @import("commands/nop.zig") },
    .{ "sxbw", 0x74, 1, @import("commands/sxbw.zig") },
    .{ "cxbw", 0x75, 1, @import("commands/cxbw.zig") },
    .{ "zxbw", 0x76, 1, @import("commands/zxbw.zig") },
    .{ "axbw", 0x77, 1, @import("commands/axbw.zig") },
    .{ "stwi", 0x78, 1, @import("commands/stwi.zig") },
    .{ "stwid",0x79, 1, @import("commands/stwid.zig") },
    .{ "arv",  0x7A, 1, @import("commands/arv.zig") },
    .{ "stsp", 0x7B, 1, @import("commands/stsp.zig") },
    .{ "sxwx", 0x7C, 1, @import("commands/sxwx.zig") },
    .{ "cxwx", 0x7D, 1, @import("commands/cxwx.zig") },
    .{ "zxwx", 0x7E, 1, @import("commands/zxwx.zig") },
    .{ "axwx", 0x7F, 1, @import("commands/axwx.zig") },
    // zig fmt: on
};
