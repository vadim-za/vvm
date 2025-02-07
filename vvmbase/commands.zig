const std = @import("std");
const Vvm = @import("Vvm.zig");

pub const table = prepareTable();

pub const Handler = *const fn (vvm: *Vvm) void;
const HandlerTable = [256]Handler;

// Prepare a table containing command handlers in positions corresponding to command codes
fn prepareTable() HandlerTable {
    var tbl: HandlerTable = [1]Handler{commands.nop.handler} ** 256;

    // Go over all public decls in 'commands' and prepare the respective table entries
    const command_decls = @typeInfo(commands).@"struct".decls;
    for (command_decls) |decl| {
        const command = @field(commands, decl.name);
        prepareCommandEntries(&tbl, command);
    }

    return tbl;
}

// Fill table entries corresponding to the specified command
fn prepareCommandEntries(tbl: []Handler, command: type) void {
    if (comptime command.descriptor.count == 1) {
        tbl[command.descriptor.base] = command.handler;
    } else {
        for (
            0..command.descriptor.count,
            command.descriptor.base..,
        ) |index, code|
            tbl[code] = command.handler(@intCast(index));
    }
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
    pub const stbr = @import("commands/stbr.zig");
    // const stwr = @import("commands/stwr.zig");
    // const xbr = @import("commands/xbr.zig");
    // const xwr = @import("commands/xwr.zig");
    // const jif = @import("commands/jif.zig");
    // const arwr = @import("commands/arwr.zig");
};
