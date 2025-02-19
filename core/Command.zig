// An intermediate description of a command, constructed (at comptime)
// from an entry in 'command_list'. These descriptions are then collected
// into a single collection available as 'Vvm.commands'.
// The latter in turn is used as a source to construct the opcode table
// in 'opcode_table.zig'.

const std = @import("std");
const Vvm = @import("Vvm.zig");
const command_list = @import("command_list.zig");
const bid = @import("bid.zig");

name: [:0]const u8,

// Opcodes for the command are in the range:
// [base_opcode .. base_opcode + variant_count] (excluding the right boundary)
base_opcode: u8,
variant_count: u8,

// the 'impl' type should publish the 'handler' function:
//      fn handler(vvm: *Vvm) void - for variant_count == 1
//      fn handler(comptime command_opcode: u8) Command.Handler - for variant_count > 1
impl: type,

pub fn init(list_entry: command_list.Entry) @This() {
    return command_list.toCommand(list_entry);
}

// -----------------------------------------------------------------------------

// The values are equal to the total number of bytes of the command
pub const Bytes = enum(u2) {
    opcode_only = 1,
    extra_byte = 2,
    extra_word = 3,
};

pub const Handler = union(Bytes) {
    opcode_only: *const fn (vvm: *Vvm) void,
    extra_byte: *const fn (vvm: *Vvm, byte: u8) void,
    extra_word: *const fn (vvm: *Vvm, word: u16) void,

    pub fn init(handler_func: anytype, command_name: []const u8) @This() {
        return switch (@TypeOf(handler_func)) {
            fn (vvm: *Vvm) void => .{
                .opcode_only = handler_func,
            },
            fn (vvm: *Vvm, byte: u8) void => .{
                .extra_byte = handler_func,
            },
            fn (vvm: *Vvm, word: u16) void => .{
                .extra_word = handler_func,
            },
            else => @compileError("Unsupported handler type for " ++ command_name),
        };
    }

    pub fn eq(self: @This(), other: @This()) bool {
        if (@as(Bytes, self) != @as(Bytes, other))
            return false;
        return switch (self) {
            inline else => |payload, tag| payload == @field(
                other,
                @tagName(tag),
            ),
        };
    }
};

pub fn handler(self: @This(), variant_index: u8) Handler {
    if (variant_index >= self.variant_count)
        @compileError("Variant index out of range for " ++ self.name);

    if (self.variantType().variantCount() != self.variant_count)
        @compileError(
            "variant_count not consistent with variant_type for " ++ self.name,
        );

    return if (self.variant_count == 1)
        .init(self.impl.handler, self.name)
    else
        .init(self.impl.handler(variant_index), self.name);
}

pub fn bytes(self: @This()) Bytes {
    return self.handler(0);
}

// -----------------------------------------------------------------------------

pub const VariantType = enum {
    none,
    byte_register,
    word_register,
    condition,

    pub fn variantCount(self: @This()) u8 {
        return switch (self) {
            .none => 1,
            .byte_register => 8,
            .word_register => 4,
            .condition => 8,
        };
    }
};

pub fn variantType(self: @This()) VariantType {
    return self.impl.variant_type;
}

// -----------------------------------------------------------------------------
// The 'opcode...()'' functions can be called at runtime! (not purely comptime)

pub fn opcodeVariant(comptime self: @This(), variant_index: usize) u8 {
    std.debug.assert(variant_index < self.variant_count);
    return @intCast(self.base_opcode + variant_index);
}

test "opcodeVariant" {
    const xbr = Vvm.commands.xbr;
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
    const add = Vvm.commands.add;
    try std.testing.expectEqual(add.base_opcode, add.opcode());
}

pub fn opcodeWithLiteral8(comptime self: @This(), literal: u8) [2]u8 {
    return .{
        self.opcode(),
        literal,
    };
}

test "opcodeWithLiteral8" {
    const lbv = Vvm.commands.lbv;
    const opcode_bytes = lbv.opcodeWithLiteral8(0x10);
    const expected = [2]u8{ lbv.base_opcode, 0x10 };
    try std.testing.expectEqualSlices(u8, &expected, &opcode_bytes);
}

pub fn opcodeWithLiteral16(comptime self: @This(), literal: u16) [3]u8 {
    return .{
        self.opcode(),
        bid.loHalf(literal),
        bid.hiHalf(literal),
    };
}

test "opcodeWithLiteral16" {
    const lwv = Vvm.commands.lwv;
    const opcode_bytes = lwv.opcodeWithLiteral16(0x1234);
    const expected = [3]u8{ lwv.base_opcode, 0x34, 0x12 };
    try std.testing.expectEqualSlices(u8, &expected, &opcode_bytes);
}
