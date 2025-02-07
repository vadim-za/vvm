const std = @import("std");
const Vvm = @import("Vvm.zig");

// This is the main table used to perform commands given their codes
pub const table: HandlerTable = makeTable();

pub const Handler = *const fn (vvm: *Vvm) void;
const HandlerTable = [256]Handler;
const default_handler = commands.nop.handler;

// Prepare a table containing command handlers in positions corresponding to command codes
fn makeTable() HandlerTable {
    var tbl: HandlerTable = [1]Handler{default_handler} ** 256;

    // Go over all public decls in 'commands' and prepare the respective table entries
    const command_decls = @typeInfo(commands).@"struct".decls;
    for (command_decls) |decl| {
        const command = @field(commands, decl.name);
        fillEntries(&tbl, command);
    }

    return tbl;
}

// Fill table entries corresponding to the specified command
fn fillEntries(tbl: []Handler, command: type) void {
    if (comptime command.descriptor.count == 1) {
        fillEntry(
            tbl,
            command.descriptor.base,
            command.handler,
        );
    } else {
        for (
            0..command.descriptor.count,
            command.descriptor.base..,
        ) |index, code|
            fillEntry(
                tbl,
                code,
                command.handler(@intCast(index)),
            );
    }
}

// Fill a single table entry
// Generates a compile-time error for duplicate fill attempts
fn fillEntry(tbl: []Handler, entry_index: usize, handler: Handler) void {
    const duplicate_fill = tbl[entry_index] != default_handler and
        handler != default_handler;
    if (comptime duplicate_fill)
        @compileError("Duplicate entry fill at index " ++
            std.fmt.comptimePrint("0x{X}", .{entry_index}));

    tbl[entry_index] = handler;
}

// Specifies the code range (from 'base' to 'base+count-1') for a command
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
            @compileError("Command range must contain at least 2 variants");
        return .{
            .base = base,
            .count = count,
        };
    }
};

const commands = struct {
    pub const lbr = @import("commands/lbr.zig");
    pub const lwr = @import("commands/lwr.zig");
    pub const stbr = @import("commands/stbr.zig");
    pub const stwr = @import("commands/stwr.zig");
    pub const xbr = @import("commands/xbr.zig");
    pub const xwr = @import("commands/xwr.zig");
    // const jif = @import("commands/jif.zig");
    pub const add = @import("commands/add.zig");
    pub const sub = @import("commands/sub.zig");
    pub const and_ = @import("commands/and.zig");
    // pub const or = @import("commands/or.zig");
    // pub const xor = @import("commands/xor.zig");
    // const arwr = @import("commands/arwr.zig");
    pub const nop = @import("commands/nop.zig");
};
