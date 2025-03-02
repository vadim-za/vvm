const std = @import("std");
const Parser = @import("../Parser.zig");
const label_parser = @import("label.zig");
const string_parser = @import("string.zig");

const ValueType = u16; // all expressions use 16 bit evaluation

fn tryParseUnsignedDecimalHere(parser: *Parser) !?ValueType {
    const in = &parser.line_in;

    var value: ValueType = 0;
    var digit_count: usize = 0;

    while (in.c) |c| : (digit_count += 1) {
        switch (c) {
            '0'...'9' => value = value *% 10 +% (c - '0'),
            else => break,
        }
        in.next();
    }

    return if (digit_count > 0) value else null;
}

fn tryParseUnsignedHexHere(parser: *Parser) !?ValueType {
    const in = &parser.line_in;

    if (in.c == '$')
        in.next()
    else
        return null;

    const pos = in.current_pos_number;

    var value: ValueType = 0;
    var digit_count: usize = 0;

    while (in.c) |c| : (digit_count += 1) {
        switch (c) {
            '0'...'9' => value = value *% 16 +% (c - '0'),
            'A'...'F' => value = value *% 16 +% ((c - 'A') + 10),
            'a'...'f' => value = value *% 16 +% ((c - 'a') + 10),
            else => break,
        }
        in.next();
    }

    return if (digit_count > 0)
        value
    else
        parser.raiseError(
            pos,
            error.BadHex,
            "bad hexadecimal number",
            .{},
        );
}

fn tryParseParenthesizedExpressionHere(
    parser: *Parser,
    allow_labels: bool,
) !?ValueType {
    const in = &parser.line_in;

    if (in.c == '(')
        in.next()
    else
        return null;

    const value = try parseExpression(
        parser,
        allow_labels,
    );

    parser.skipWhitespace();
    const pos = in.current_pos_number;

    if (in.c == ')')
        in.next()
    else
        return parser.raiseError(
            pos,
            error.ClosingParExpected,
            "')' expected",
            .{},
        );

    return value;
}

fn tryParseLiteralHere(parser: *Parser) !?ValueType {
    if (try tryParseUnsignedDecimalHere(parser)) |value|
        return value;

    if (try tryParseUnsignedHexHere(parser)) |value|
        return value;

    if (try string_parser.tryParseStringAsValueHere(
        parser,
        ValueType,
    )) |value|
        return value;

    return null;
}

fn parseUnsignedTerm(parser: *Parser, allow_labels: bool) !ValueType {
    parser.skipWhitespace();

    const in = &parser.line_in;
    const pos = in.current_pos_number;

    if (try tryParseParenthesizedExpressionHere(
        parser,
        allow_labels,
    )) |value|
        return value;

    if (try tryParseLiteralHere(parser)) |value|
        return value;

    if (try label_parser.tryParseLabelAsValueHere(parser)) |value| {
        return if (allow_labels)
            value
        else
            return parser.raiseError(
                pos,
                error.LabelNotAllowed,
                "labels are not allowed here",
                .{},
            );
    }

    return parser.raiseError(
        pos,
        error.ExprTermExpected,
        "an expression term expected",
        .{},
    );
}

fn parseTerm(parser: *Parser, allow_labels: bool) !ValueType {
    const in = &parser.line_in;
    parser.skipWhitespace();

    const negate = switch (in.c orelse 0) {
        '+' => blk: {
            in.next();
            break :blk false;
        },
        '-' => blk: {
            in.next();
            break :blk true;
        },
        else => false,
    };

    const value = try parseUnsignedTerm(
        parser,
        allow_labels,
    );
    return if (negate) -%value else value;
}

fn parseExpression(
    parser: *Parser,
    allow_labels: bool,
) Parser.Error!ValueType {
    const in = &parser.line_in;

    var sum = try parseTerm(parser, allow_labels);
    while (true) {
        parser.skipWhitespace();
        switch (in.c orelse 0) {
            '+' => {
                in.next();
                sum +%= try parseTerm(parser, allow_labels);
            },
            '-' => {
                in.next();
                sum -%= try parseTerm(parser, allow_labels);
            },
            else => break,
        }
    }

    return sum;
}

pub fn parseExpressionAs(parser: *Parser, T: type, allow_labels: bool) !T {
    return @truncate(
        try parseExpression(parser, allow_labels),
    );
}

pub fn parseParenthesizedExpressionAs(parser: *Parser, T: type, allow_labels: bool) !T {
    parser.skipWhitespace();

    const in = &parser.line_in;
    const pos = in.current_pos_number;

    return @truncate(
        (try tryParseParenthesizedExpressionHere(
            parser,
            allow_labels,
        )) orelse return parser.raiseError(
            pos,
            error.ParExprExpected,
            "parenthesized expression expected",
            .{},
        ),
    );
}

test "Test" {
    const SourceInput = @import("../SourceInput.zig");
    const Label = @import("../Label.zig");

    const ExpressionTest = struct {
        []const u8,
        type,
        Parser.Error!u16,
        ?Parser.ErrorInfo.InitTuple,
    };
    const expressions = [_]ExpressionTest{
        .{ "0", u16, 0, null },
        .{ "1", u8, 1, null },
        .{ "-10", u8, -%@as(u8, 10), null },
        .{ "+1000", u16, 1000, null },
        .{ "10+21", u8, 31, null },
        .{ "10-$21", u16, 10 -% @as(u16, 0x21), null },
        .{ "10-abc", u16, 10 -% @as(u16, 1000), null },
        .{ "$-1", u16, error.SyntaxError, .{ 1, 2, error.BadHex } },
        .{ "0-ab1", u16, error.SyntaxError, .{ 1, 3, error.UnknownLabel } },
        .{ "(0-1", u16, error.SyntaxError, .{ 1, 5, error.ClosingParExpected } },
        .{ "(?)", u16, error.SyntaxError, .{ 1, 2, error.ExprTermExpected } },
    };

    inline for (&expressions) |expr_test| {
        const source = expr_test[0];
        const T = expr_test[1];
        const expected_result: Parser.Error!T = expr_test[2];
        const expected_error = expr_test[3];

        var in = SourceInput.init(source);
        var error_info: ?Parser.ErrorInfo = null;
        var parser: Parser = .init(
            std.testing.allocator,
            &in,
            &error_info,
        );
        defer parser.deinit();

        try parser.labels.push(.{
            .stored_name = Label.initStoredName("abc"),
            .line = 1,
            .addr = 1000,
        });
        try parser.labels.finalize(&parser);

        const parse_result =
            parseExpressionAs(&parser, T, true);
        try std.testing.expectEqual(expected_result, parse_result);

        if (comptime expected_result == error.SyntaxError) {
            try std.testing.expectEqual(error.SyntaxError, parse_result);
            try std.testing.expect(error_info.?.eqTuple(expected_error.?));
        } else std.debug.assert(expected_error == null);
    }
}
