const std = @import("std");
const Vvm = @import("Vvm.zig");
const Command = @import("Command.zig");

// This is the main table used to perform commands given their codes
pub const table: HandlerTable = makeTable();

const HandlerTable = [256]TableEntry;
const TableEntry = *const Command.Handler;
const default_entry: TableEntry = Command.collection.nop.handler(0);

// Prepare a table containing command handlers in positions corresponding to command codes
fn makeTable() HandlerTable {
    var tbl: HandlerTable = [1]TableEntry{default_entry} ** 256;

    // Go over all fields in 'Command.collection' and prepare the respective table entries
    const collection = &Command.collection;
    for (@typeInfo(@TypeOf(collection.*)).@"struct".fields) |*field| {
        const command = @field(collection, field.name);
        for (
            0..command.variant_count,
            command.base_code..,
        ) |index, code|
            fillEntry(
                &tbl,
                code,
                command.handler(@intCast(index)),
                field.name,
            );
    }

    return tbl;
}

// Fill a single table entry
// Generates a compile-time error for duplicate fill attempts
fn fillEntry(
    tbl: []TableEntry,
    entry_index: usize,
    handler: TableEntry,
    command_name: []const u8,
) void {
    const duplicate_fill = tbl[entry_index] != default_entry and
        handler != default_entry;
    if (comptime duplicate_fill)
        @compileError("Duplicate entry fill at index " ++
            std.fmt.comptimePrint("0x{X}", .{entry_index}) ++
            " for command " ++ command_name);

    tbl[entry_index] = handler;
}
