const std = @import("std");
const Vvm = @import("Vvm.zig");
const command_list = @import("command_list.zig");

name: []const u8,

// Machine codes for the command are in the range:
// [base_code .. base_code + variant_count] (excluding the right boundary)
base_code: u8,
variant_count: u8,

// the 'impl' type should publish the 'handler' function:
//      fn handler(vvm: *Vvm) void - for count == 1
//      fn handler(comptime command_code: u8) fn (*Vvm) void - for count > 1
impl: type,

// A struct contaning all commands as its fields (of Command type each).
// (This is actually a backwards dependency, the Command should not depend
// on command_collection. However it allows convenient usage by simply
// referring to it as 'Commmand.collection'. We can also utilize some
// of its commands it to reduce the amount of code in unit tests for the
// 'Command.code...()' functions. So we allow it as an exception.)
pub const collection = command_collection.collectAll();
const command_collection = @import("command_collection.zig");

// Construct a command from a given entry in the 'command_list'
pub fn init(command_name: []const u8) @This() {
    const ListEntry = struct {
        u8, // base_command_code
        u8, // variant_count
        type, // impl
    };
    const list_entry: ListEntry = @field(command_list, command_name);

    return .{
        .name = command_name,
        .base_code = list_entry[0],
        .variant_count = list_entry[1],
        .impl = list_entry[2],
    };
}

pub const Handler = fn (vvm: *Vvm) void;

pub fn handler(self: @This(), variant_index: u8) *const Handler {
    if (variant_index >= self.variant_count)
        @compileError("Index out of range for " ++ self.name);

    return if (self.variant_count == 1)
        self.impl.handler
    else
        self.impl.handler(variant_index);
}

// -----------------------------------------------------------------------------
// The 'code...()'' functions can be called at runtime! (not purely comptime)

pub fn codeVariant(comptime self: @This(), variant_index: usize) u8 {
    std.debug.assert(variant_index < self.variant_count);
    return @intCast(self.base_code + variant_index);
}

test "codeVariant" {
    const xbr = collection.xbr;
    for (0..xbr.variant_count) |n|
        try std.testing.expectEqual(
            xbr.base_code + @as(u8, @intCast(n)),
            xbr.codeVariant(n),
        );
}

pub fn code(comptime self: @This()) u8 {
    return self.codeVariant(0);
}

test "code" {
    const add = collection.add;
    try std.testing.expectEqual(add.base_code, add.code());
}

pub fn codeWithLiteral8(comptime self: @This(), literal: u8) [2]u8 {
    return .{
        self.code(),
        literal,
    };
}

test "codeWithLiteral8" {
    const lbv = collection.lbv;
    const bytes = lbv.codeWithLiteral8(0x10);
    const expected = [2]u8{ lbv.base_code, 0x10 };
    try std.testing.expectEqualSlices(u8, &expected, &bytes);
}

pub fn codeWithLiteral16(comptime self: @This(), literal: u16) [3]u8 {
    return .{
        self.code(),
        @intCast(literal & 0xFF), // LSB
        @intCast(literal >> 8), // MSB
    };
}

test "codeWithLiteral16" {
    const lwv = collection.lwv;
    const bytes = lwv.codeWithLiteral16(0x1234);
    const expected = [3]u8{ lwv.base_code, 0x34, 0x12 };
    try std.testing.expectEqualSlices(u8, &expected, &bytes);
}
