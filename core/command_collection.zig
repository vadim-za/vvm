const std = @import("std");
const command_list = @import("command_list.zig");
const Command = @import("Command.zig");

// Construct a collection of all commands in 'command_list'. Comptime only.
// See MakeFullCollectionType() for further info.
pub fn collectAll() FullCollection {
    return .{}; // the type already defines all necessary field values as defaults
}

const FullCollection = MakeFullCollectionType();

// For each entry in 'command_list.commands' the constructed type contains
// a named field of type Command, the name being taken from the entry.
// It looks smth like:
// struct {
//      lbr: Command = .init(command_list.commands[0]),
//      lwr: Command = .init(command_list.commands[1]),
//      ...
// }
// This allows accessing the collection items simply as 'collection.lbr',
// 'collection.lwr' etc.
fn MakeFullCollectionType() type {
    const list_entries = &command_list.commands;
    const total_count = list_entries.len;

    const StructField = std.builtin.Type.StructField;
    var fields: [total_count]StructField = undefined;

    for (list_entries, &fields) |list_entry, *field| {
        const command = Command.init(list_entry);

        field.* = .{
            .name = command.name,
            .type = Command,
            .default_value = &command,
            .is_comptime = false, // will be used only in purely comptime code anyway
            .alignment = 0,
        };
    }

    return @Type(.{
        .@"struct" = .{
            .layout = .auto,
            .fields = &fields,
            .decls = &.{},
            .is_tuple = false,
        },
    });
}
