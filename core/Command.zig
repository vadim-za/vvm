// An intermediate description of a command, constructed (at comptime)
// from an entry in 'command_list'. These descriptions are then collected
// into a single collection available as 'Command.collection'.
// The latter in turn is used as a source to construct the opcode table
// in 'command_table.zig'.

const std = @import("std");
const Vvm = @import("Vvm.zig");
const command_list = @import("command_list.zig");
const bid = @import("bid.zig");

name: []const u8,

// Opcodes for the command are in the range:
// [base_opcode .. base_opcode + variant_count] (excluding the right boundary)
base_opcode: u8,
variant_count: u8,

// the 'impl' type should publish the 'handler' function:
//      fn handler(vvm: *Vvm) void - for variant_count == 1
//      fn handler(comptime command_opcode: u8) Command.Handler - for variant_count > 1
impl: type,

// A struct containing all commands as its fields (of Command type each).
// (This is actually a backwards dependency, the Command should not depend
// on command_collection. However it allows convenient usage by simply
// referring to it as 'Commmand.collection'. We can also utilize some
// of its commands it to reduce the amount of helper code in unit tests.
// So we allow it as an exception.)
pub const collection = command_collection.collectAll();
const command_collection = @import("command_collection.zig");

// Construct a command from a given entry in the 'command_list'.
// 'command_name' specifies the entry name.
pub fn init(command_name: []const u8) @This() {
    const ListEntry = struct {
        u8, // base_command_code
        u8, // variant_count
        type, // impl
    };
    const list_entry: ListEntry = @field(command_list, command_name);

    return .{
        .name = command_name,
        .base_opcode = list_entry[0],
        .variant_count = list_entry[1],
        .impl = list_entry[2],
    };
}

pub const Handler = fn (vvm: *Vvm) void;

pub fn handler(self: @This(), variant_index: u8) *const Handler {
    if (variant_index >= self.variant_count)
        @compileError("Variant index out of range for " ++ self.name);

    return if (self.variant_count == 1)
        self.impl.handler
    else
        self.impl.handler(variant_index);
}

// -----------------------------------------------------------------------------
// The 'opcode...()'' functions can be called at runtime! (not purely comptime)

pub fn opcodeVariant(comptime self: @This(), variant_index: usize) u8 {
    std.debug.assert(variant_index < self.variant_count);
    return @intCast(self.base_opcode + variant_index);
}

test "opcodeVariant" {
    const xbr = collection.xbr;
    for (0..xbr.variant_count) |n|
        try std.testing.expectEqual(
            xbr.base_opcode + @as(u8, @intCast(n)),
            xbr.opcodeVariant(n),
        );
}

pub fn opcode(comptime self: @This()) u8 {
    return self.opcodeVariant(0);
}

test "opcode" {
    const add = collection.add;
    try std.testing.expectEqual(add.base_opcode, add.opcode());
}

pub fn opcodeWithLiteral8(comptime self: @This(), literal: u8) [2]u8 {
    return .{
        self.opcode(),
        literal,
    };
}

test "opcodeWithLiteral8" {
    const lbv = collection.lbv;
    const bytes = lbv.opcodeWithLiteral8(0x10);
    const expected = [2]u8{ lbv.base_opcode, 0x10 };
    try std.testing.expectEqualSlices(u8, &expected, &bytes);
}

pub fn opcodeWithLiteral16(comptime self: @This(), literal: u16) [3]u8 {
    return .{
        self.opcode(),
        bid.loHalf(literal),
        bid.hiHalf(literal),
    };
}

test "opcodeWithLiteral16" {
    const lwv = collection.lwv;
    const bytes = lwv.opcodeWithLiteral16(0x1234);
    const expected = [3]u8{ lwv.base_opcode, 0x34, 0x12 };
    try std.testing.expectEqualSlices(u8, &expected, &bytes);
}
