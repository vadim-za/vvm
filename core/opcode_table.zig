// The following decl ('table') is the main opcode table used to perform commands
// given their opcodes. A command opcode is used as an index into this table,
// the respective entry of the table is pointing to the command handler.
pub const table: HandlerTable = makeTable();

const std = @import("std");
const Vvm = @import("Vvm.zig");
const Command = @import("Command.zig");

const HandlerTable = [256]TableEntry;
const TableEntry = Command.Handler;
const default_entry: TableEntry = .init(unusedOpcodeHandler, "default_entry");

// Prepare a table containing command handlers in positions corresponding to command opcodes
fn makeTable() HandlerTable {
    var tbl: HandlerTable = [1]TableEntry{default_entry} ** 256;

    // Go over all fields in 'Vvm.commands' and prepare the respective table entries
    const commands = &Vvm.commands;
    for (@typeInfo(@TypeOf(commands.*)).@"struct".fields) |*field| {
        const command = @field(commands, field.name);
        for (
            0..command.variant_count,
            command.base_opcode..,
        ) |index, opcode|
            fillEntry(
                &tbl,
                opcode,
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
    const duplicate_fill = !tbl[entry_index].eq(default_entry);
    if (comptime duplicate_fill)
        @compileError("Duplicate entry fill at index " ++
            std.fmt.comptimePrint("0x{X}", .{entry_index}) ++
            " for command " ++ command_name);

    tbl[entry_index] = handler;
}

// Use a handler separate from NOP for unused table entries,
// so that we can correctly detect duplicates
fn unusedOpcodeHandler(_: *Vvm) void {}
