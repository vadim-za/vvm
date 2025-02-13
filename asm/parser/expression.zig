const Parser = @import("../Parser.zig");

fn tryParseUnsignedDecimalHere(parser: *Parser, T: type) !?T {
    const in = &parser.line_in;

    var value: T = 0;
    var digit_count: usize = 0;

    while (in.c) |c| : (digit_count += 1) {
        switch (c) {
            '0'...'9' => value = value *| 10 +| (c - '0'),
            else => break,
        }
        in.next();
    }

    return if (digit_count > 0) value else null;
}

fn tryParseUnsignedHexHere(parser: *Parser, T: type) !?T {
    const in = &parser.line_in;

    if (in.c == '$')
        in.next()
    else
        return null;

    const pos = in.current_pos_number;

    var value: T = 0;
    var digit_count: usize = 0;

    while (in.c) |c| : (digit_count += 1) {
        switch (c) {
            '0'...'9' => value = value *| 16 +| (c - '0'),
            'A'...'F' => value = value *| 16 +| ((c - 'A') + 10),
            'a'...'f' => value = value *| 16 +| ((c - 'a') + 10),
            else => break,
        }
        in.next();
    }

    return if (digit_count > 0)
        value
    else
        parser.raiseError(pos, "bad hexadecimal number", .{});
}

fn tryParseLabelAsValueHere(parser: *Parser, T: type) !?T {
    const name = (try parser.tryParseLabelNameHere()) orelse return null;
    _ = name; // autofix
    if (parser.labels.finalized) {
        unreachable; // todo
    }
    return 0;
}

fn parseUnsignedConstantTermHere(parser: *Parser, T: type) !T {
    const in = &parser.line_in;
    const pos = in.current_pos_number;

    if (try tryParseUnsignedDecimalHere(parser, T)) |value|
        return value;

    if (try tryParseUnsignedHexHere(parser, T)) |value|
        return value;

    if (try tryParseLabelAsValueHere(parser, T)) |value|
        return value;

    return parser.raiseError(pos, "a number or a label is expected", .{});
}

fn parseConstantTerm(parser: *Parser, T: type) !T {
    const in = &parser.line_in;
    parser.skipWhitespace();

    var negate: ?bool = null;
    switch (in.c orelse 0) {
        '+' => negate = false,
        '-' => negate = true,
        else => {},
    }

    if (negate != null) {
        in.next();
        parser.skipWhitespace();
    } else negate = false;

    const value = try parseUnsignedConstantTermHere(parser, T);
    return if (negate.?) 0 -| value else value;
}

pub fn parseConstantExpression(parser: *Parser, T: type) !T {
    const in = &parser.line_in;

    var sum = try parseConstantTerm(parser, T);
    while (true) {
        parser.skipWhitespace();
        switch (in.c orelse 0) {
            '+' => sum +|= try parseConstantTerm(parser, T),
            '-' => sum -|= try parseConstantTerm(parser, T),
            else => break,
        }
    }

    return sum;
}
