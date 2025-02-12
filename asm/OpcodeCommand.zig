const std = @import("std");
const VvmCore = @import("VvmCore");
const Asm = @import("Asm.zig");
const Command = @import("Command.zig");

base_opcode: u8,
variant_count: u8,
variant_type: VvmCore.Command.VariantType,

pub fn translate(self: *const @This(), @"asm": *Asm) !void {
    const semantics: *const Command.Semantics =
        @alignCast(@fieldParentPtr("opcode", self));
    const command: *const Command =
        @alignCast(@fieldParentPtr("semantics", semantics));
    const bytes = command.bytes;

    const opcode: u8 = switch (self.variant_type) {
        .none => self.base_opcode,
        .byte_register => try self.parseByteRegister(@"asm"),
        .word_register => try self.parseWordRegister(@"asm"),
        .condition => try self.parseCondition(@"asm"),
    };
    try @"asm".writeByte(opcode);

    if (self.variant_type != .none and bytes != .opcode_only)
        try @"asm".readOptionallyWhitespacedComma();

    switch (bytes) {
        .opcode_only => {},
        .extra_byte => try @"asm".writeByte(try command.parseByte(@"asm")),
        .extra_word => try @"asm".writeWord(try command.parseWord(@"asm")),
    }
}

fn parseByteRegister(self: *const @This(), @"asm": *Asm) !u8 {
    const in = &@"asm".line_in;
    @"asm".skipWhitespace();

    if (!in.isAtUpper('B'))
        return @"asm".raiseError("expected byte register name 'Bn'", .{});
    in.next();

    const n = @"asm".readUnsignedDecimal();

    if (n >= self.variant_count)
        return @"asm".raiseError(
            "register index must be between 0 and {}",
            .{self.variant_count - 1},
        );

    return @intCast(n);
}

fn parseWordRegister(self: *const @This(), @"asm": *Asm) !u8 {
    const in = &@"asm".line_in;
    @"asm".skipWhitespace();

    if (!in.isAtUpper('W'))
        return @"asm".raiseError("expected word register name 'Wn'", .{});
    in.next();

    const n = @"asm".readUnsignedDecimal();

    if (n >= self.variant_count)
        return @"asm".raiseError(
            "register index must be between 0 and {}",
            .{self.variant_count - 1},
        );

    return @intCast(n);
}
