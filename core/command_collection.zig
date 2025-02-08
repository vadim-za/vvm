const std = @import("std");
const command_list = @import("command_list.zig");
const Command = @import("Command.zig");

// Construct a collection of all commands in 'command_list'. Comptime only.
// See MakeFullCollectionType() for further info.
pub fn collectAll() FullCollection {
    return .{}; // the type already defines all necessary field values as defaults
}

const FullCollection = MakeFullCollectionType();

// For each pub decl in 'command_list' the constructed type contains
// an identically named field of type Command. Thus it looks smth like:
// struct {
//      lbr: Command = .init("lbr"),
//      lwr: Command = .init("lwr"),
//      ...
// }
fn MakeFullCollectionType() type {
    const list_entries = @typeInfo(command_list).@"struct".decls;
    const total_count = list_entries.len;

    const StructField = std.builtin.Type.StructField;
    var fields: [total_count]StructField = undefined;

    for (list_entries, &fields) |*decl, *field| {
        const name = decl.name;
        const command = Command.init(name);

        field.* = .{
            .name = name,
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
