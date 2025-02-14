const std = @import("std");
const VvmCore = @import("VvmCore");

pub const Command = struct {
    name: []const u8,
    bytes: VvmCore.Command.Bytes,
    base_opcode: u8,
    variant_count: u8,
    variant_type: VvmCore.Command.VariantType,
};

const vvm_commands = VvmCore.commands;
const vvm_commands_fields =
    @typeInfo(@TypeOf(vvm_commands)).@"struct".fields;
const command_count = vvm_commands_fields.len;

// Use a sorted array until Zig issue 12250 is addressed,
// at which point we could consider using nested auto-generated switches.
const table: [command_count]Command = blk: {
    var temp_table: [command_count]Command = undefined;

    @setEvalBranchQuota(5000);

    for (&temp_table, vvm_commands_fields) |*entry, *field| {
        const desc = @field(vvm_commands, field.name);

        entry.* = .{
            .name = comptimeToUpperString(field.name),
            .bytes = desc.bytes(),
            .base_opcode = desc.base_opcode,
            .variant_count = desc.variant_count,
            .variant_type = desc.variantType(),
        };
    }

    std.sort.heap(Command, &temp_table, {}, lessThan);

    break :blk temp_table;
};

fn comptimeToUpperString(comptime s: []const u8) []const u8 {
    var upper: [s.len]u8 = undefined;
    _ = std.ascii.upperString(
        &upper,
        s,
    );

    const const_upper = upper;
    return &const_upper;
}

fn lessThan(context: void, lhs: Command, rhs: Command) bool {
    _ = context;
    return std.mem.order(u8, lhs.name, rhs.name) == .lt;
}

fn compare(context: []const u8, item: Command) std.math.Order {
    return std.mem.order(u8, context, item.name);
}

pub fn findUppercase(uppercase_name: []const u8) ?Command {
    return if (std.sort.binarySearch(
        Command,
        &table,
        uppercase_name,
        compare,
    )) |index| table[index] else null;
}

pub fn dumpTable() void {
    for (&table) |entry|
        std.debug.print("{s} {}\n", .{ entry.name, entry });
}
