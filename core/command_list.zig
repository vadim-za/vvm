// zig fmt: off

pub const   lbr  = .{ 0x00, 8, @import("commands/lbr.zig") };
pub const   lwr  = .{ 0x08, 4, @import("commands/lwr.zig") };
pub const   stbr = .{ 0x10, 8, @import("commands/stbr.zig") };
pub const   stwr = .{ 0x18, 4, @import("commands/stwr.zig") };
pub const   xbr  = .{ 0x20, 8, @import("commands/xbr.zig") };
pub const   xwr  = .{ 0x28, 4, @import("commands/xwr.zig") };
// // const jif = @import("commands/jif.zig");
pub const   add  = .{ 0x40, 1, @import("commands/add.zig") };
pub const   sub  = .{ 0x41, 1, @import("commands/sub.zig") };
pub const @"and" = .{ 0x42, 1, @import("commands/and.zig") };
pub const @"or"  = .{ 0x43, 1, @import("commands/or.zig") };
pub const @"xor" = .{ 0x44, 1, @import("commands/xor.zig") };
// // pub const jmp = @import("commands/jmp.zig");
// // pub const call = @import("commands/call.zig");
// // pub const ret = @import("commands/ret.zig");
pub const   arwr = .{ 0x48, 4, @import("commands/arwr.zig") };
pub const   zero = .{ 0x50, 1, @import("commands/zero.zig") };
pub const   all  = .{ 0x51, 1, @import("commands/all.zig") };
pub const   cpl  = .{ 0x52, 1, @import("commands/cpl.zig") };
pub const   xhl  = .{ 0x53, 1, @import("commands/xhl.zig") };
// // pub const   in  = .{ 0x54, 1, @import("commands/in.zig") };
// // pub const   out  = .{ 0x55, 1, @import("commands/out.zig") };
pub const   rol  = .{ 0x58, 1, @import("commands/rol.zig") };
pub const   ror  = .{ 0x59, 1, @import("commands/ror.zig") };
pub const   ara  = .{ 0x5A, 1, @import("commands/ara.zig") };
pub const   xa   = .{ 0x5B, 1, @import("commands/xa.zig") };
pub const   pop  = .{ 0x5C, 1, @import("commands/pop.zig") };
pub const   push = .{ 0x5D, 1, @import("commands/push.zig") };
pub const   lbi  = .{ 0x60, 1, @import("commands/lbi.zig") };
pub const   lbv  = .{ 0x62, 1, @import("commands/lbv.zig") };
// pub const in = @import("commands/in.zig");
// pub const lwi = @import("commands/lwi.zig");
pub const   lwv  = .{ 0x6A, 1, @import("commands/lwv.zig") };
// pub const lsp = @import("commands/lsp.zig");
pub const   nop  = .{ 0x72, 1, @import("commands/nop.zig") };

// zig fmt: on
