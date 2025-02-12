const std = @import("std");
const VvmCore = @import("VvmCore");
const Parser = @import("Parser.zig");
const PassOutput = @import("PassOutput.zig");

name: []const u8,
bytes: VvmCore.Command.Bytes,
base_opcode: u8,
variant_count: u8,
variant_type: VvmCore.Command.VariantType,

pub fn translate(self: @This(), parser: *Parser, out: *PassOutput) !void {
    const opcode: u8 = switch (self.variant_type) {
        .none => self.base_opcode,
        .byte_register => try self.parseByteRegister(parser),
        .word_register => try self.parseWordRegister(parser),
        .condition => try self.parseCondition(parser),
    };
    try out.writeByte(opcode);

    if (self.variant_type != .none and self.bytes != .opcode_only)
        try parser.readOptionallyWhitespacedComma();

    switch (self.bytes) {
        .opcode_only => {},
        .extra_byte => try out.writeByte(try parser.parseByteValue()),
        .extra_word => try out.writeWord(try parser.parseWordValue()),
    }
}
