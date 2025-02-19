const std = @import("std");
const Parser = @import("../Parser.zig");
const PassOutput = @import("../PassOutput.zig");
const commands = @import("../commands.zig");
const register_parser = @import("register.zig");
const expression_parser = @import("expression.zig");
const condition_parser = @import("condition.zig");

const Command = commands.Command;

fn parseOptionallyWhitespacedComma(parser: *Parser) !void {
    const in = &parser.line_in;
    parser.skipWhitespace();

    const pos = in.current_pos_number;
    if (in.c == ',')
        in.next()
    else
        return parser.raiseError(pos, "comma expected", .{});

    parser.skipWhitespace();
}

pub fn translateCommandHere(command: Command, parser: *Parser, out: *PassOutput) !void {
    parser.pc +%= @intFromEnum(command.bytes);

    if (command.variant_type != .none)
        try parser.requireAndSkipWhitespace();

    const opcode: u8 = command.base_opcode + switch (command.variant_type) {
        .none => 0,
        .byte_register => try register_parser.parseRegisterName(
            parser,
            'B',
            "byte",
            8,
        ),
        .word_register => try register_parser.parseRegisterName(
            parser,
            'W',
            "word",
            4,
        ),
        .condition => try condition_parser.parseCondition(parser),
    };
    try out.writeByte(opcode, parser);

    if (command.variant_type != .none and command.bytes != .opcode_only)
        try parseOptionallyWhitespacedComma(parser);

    switch (command.bytes) {
        .opcode_only => {},
        .extra_byte => try out.writeByte(
            try expression_parser.parseExpressionAs(
                parser,
                u8,
                true,
            ),
            parser,
        ),
        .extra_word => try out.writeWord(
            try expression_parser.parseExpressionAs(
                parser,
                u16,
                true,
            ),
            parser,
        ),
    }
}

pub fn parseCommandHere(parser: *Parser, out: *PassOutput) !void {
    const in = &parser.line_in;
    const pos = in.current_pos_number;

    const max_name = 8;
    var name_buffer: std.BoundedArray(u8, max_name) = .{};

    if (!in.isAtAlphabetic())
        return parser.raiseError(
            pos,
            "instruction name must begin with a letter",
            .{},
        );

    while (in.isAtAlphabetic()) {
        name_buffer.append(in.c.?) catch
            return parser.raiseError(
            pos,
            "instruction name too long (max length = {})",
            .{max_name},
        );
        in.next();
    }

    const name = name_buffer.slice();
    _ = std.ascii.upperString(name, name);
    const command = commands.findUppercase(name) orelse
        return parser.raiseError(
        pos,
        "unknown instruction name '{s}'",
        .{name},
    );

    try translateCommandHere(command, parser, out);
}

test "Test parse errors" {
    const @"asm" = @import("../asm.zig");

    const Test = struct { []const u8, ?usize };
    const tests = [_]Test{
        .{ " ara 1", 6 }, // unexpected operand
        .{ " ara;", null },
        .{ " jif lnz", null },
        .{ " cmd b0", 2 }, // wrong mnemonic
    };

    for (&tests) |t| {
        const source = t[0];
        const expected_error_pos = t[1];

        var error_info: Parser.ErrorInfo = undefined;
        const result =
            @"asm".translateSource(
            std.testing.allocator,
            source,
            &error_info,
        );
        defer {
            // Deinit only if not error
            if (result) |container| container.deinit() else |_| {}
        }

        if (expected_error_pos) |pos| {
            try std.testing.expectEqual(error.SyntaxError, result);
            try std.testing.expect(error_info.isAt(1, pos));
        } else {
            _ = try result; // fail upon a returned error
        }
    }
}
