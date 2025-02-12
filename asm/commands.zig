const std = @import("std");
const VvmCore = @import("VvmCore");
const Command = @import("Command.zig");

const vvm_commands = VvmCore.commands;
const vvm_commands_fields =
    @typeInfo(@TypeOf(vvm_commands)).@"struct".fields;
const command_count = vvm_commands_fields.len;

const table: [command_count]Command = blk: {
    var temp_table: [command_count]Command = undefined;

    for (&temp_table, vvm_commands_fields) |*entry, *field| {
        const desc = @field(vvm_commands, field.name);
        const uppercase_name: [field.name.len]u8 = inner_blk: {
            var temp: [field.name.len]u8 = undefined;
            _ = std.ascii.upperString(
                &temp,
                field.name,
            );
            break :inner_blk temp;
        };

        entry.* = .{
            .name = &uppercase_name,
            .bytes = desc.bytes(),
            .base_opcode = desc.base_opcode,
            .variant_count = desc.variant_count,
            .variant_type = desc.variantType(),
        };
    }

    @setEvalBranchQuota(10000);
    std.sort.heap(Command, &temp_table, {}, lessThanFn);

    break :blk temp_table;
};

fn lessThanFn(context: void, lhs: Command, rhs: Command) bool {
    _ = context;
    return std.mem.order(u8, lhs.name, rhs.name) == .lt;
}

fn compareFn(context: []const u8, item: Command) std.math.Order {
    return std.mem.order(u8, context, item.name);
}

pub fn findUppercase(uppercase_name: []const u8) ?*const Command {
    return if (std.sort.binarySearch(
        Command,
        &table,
        uppercase_name,
        compareFn,
    )) |index| &table[index] else null;
}

pub fn dumpTable() void {
    for(&table) |entry|
        std.debug.print("{s} {}\n",.{entry.name, entry});
}
