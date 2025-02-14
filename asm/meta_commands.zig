const std = @import("std");
const Parser = @import("Parser.zig");
const PassOutput = @import("PassOutput.zig");
const mc_parser = @import("parser/meta_command.zig");

pub const ListEntry = struct {
    []const u8,
    *const fn (parser: *Parser, out: *PassOutput) Parser.Error!void,
};

fn toCommand(entry: ListEntry) MetaCommand {
    return .{
        .name = entry[0],
        .translate = entry[1],
    };
}

const MetaCommand = struct {
    name: []const u8,
    translate: *const fn (parser: *Parser, out: *PassOutput) Parser.Error!void,
};

const list = mc_parser.meta_command_list;

pub const table: [list.len]MetaCommand = blk: {
    var temp_table: [list.len]MetaCommand = undefined;

    @setEvalBranchQuota(5000);

    for (&temp_table, &list) |*temp_entry, list_entry|
        temp_entry.* = toCommand(list_entry);
    std.sort.heap(MetaCommand, &temp_table, {}, lessThan);

    break :blk temp_table;
};

fn lessThan(context: void, lhs: MetaCommand, rhs: MetaCommand) bool {
    _ = context;
    return std.mem.order(u8, lhs.name, rhs.name) == .lt;
}

fn compare(context: []const u8, item: MetaCommand) std.math.Order {
    return std.mem.order(u8, context, item.name);
}

pub fn findUppercase(uppercase_name: []const u8) ?MetaCommand {
    return if (std.sort.binarySearch(
        MetaCommand,
        &table,
        uppercase_name,
        compare,
    )) |index| table[index] else null;
}
