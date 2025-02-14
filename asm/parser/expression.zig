const std = @import("std");
const Parser = @import("../Parser.zig");
const label_parser = @import("label.zig");
const Label = @import("../Label.zig");

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
        parser.raiseError(pos, "bad hexadecimal number", .{});
}

fn parseUnsignedConstantTermHere(parser: *Parser) !ValueType {
    const in = &parser.line_in;
    const pos = in.current_pos_number;

    if (try tryParseUnsignedDecimalHere(parser)) |value|
        return value;

    if (try tryParseUnsignedHexHere(parser)) |value|
        return value;

    if (try label_parser.tryParseLabelAsValueHere(parser)) |value|
        return value;

    return parser.raiseError(pos, "a number or a label is expected", .{});
}

fn parseConstantTerm(parser: *Parser) !ValueType {
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

    parser.skipWhitespace();
    const value = try parseUnsignedConstantTermHere(parser);
    return if (negate) 0 -% value else value;
}

fn parseConstantExpression(parser: *Parser) !ValueType {
    const in = &parser.line_in;

    var sum = try parseConstantTerm(parser);
    while (true) {
        parser.skipWhitespace();
        switch (in.c orelse 0) {
            '+' => {
                in.next();
                sum +%= try parseConstantTerm(parser);
            },
            '-' => {
                in.next();
                sum -%= try parseConstantTerm(parser);
            },
            else => break,
        }
    }

    return sum;
}

pub fn parseConstantExpressionAs(parser: *Parser, T: type) !T {
    return @truncate(
        parseConstantExpression(parser) catch |err| return err,
    );
}

test "Test" {
    const SourceInput = @import("../SourceInput.zig");

    const ExpressionTest = struct { []const u8, type, u16 };
    const expressions = [_]ExpressionTest{
        .{ "0", u16, 0 },
        .{ "1", u8, 1 },
        .{ "-10", u8, 0 -% @as(u8, 10) },
        .{ "+1000", u16, 1000 },
        .{ "10+21", u8, 31 },
        .{ "10-21", u16, 10 -% @as(u16, 21) },
        .{ "10-abc", u16, 10 -% @as(u16, 1000) },
    };
    inline for (&expressions) |expr_test| {
        const source = expr_test[0];
        const T = expr_test[1];
        const expected_value = expr_test[2];
        var in = SourceInput.init(source);
        var parser: Parser = .init(std.testing.allocator, &in);
        defer parser.deinit();
        try parser.labels.push(.{
            .stored_name = Label.initStoredName("abc"),
            .line = 1,
            .addr = 1000,
        });
        try parser.labels.finalize(&parser);
        const parsed_value = try parseConstantExpressionAs(&parser, T);
        try std.testing.expectEqual(expected_value, parsed_value);
    }
}
