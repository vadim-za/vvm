const std = @import("std");
const Parser = @import("../Parser.zig");

// This function always succeeds, since condition register may be empty
fn parseConditionRegisterHere(parser: *Parser) u8 {
    const in = &parser.line_in;

    var register_code: ?u8 = switch (in.c orelse 0) {
        'H' => 1,
        'L' => 0,
        'X' => 3,
        else => null,
    };

    if (register_code != null)
        in.next()
    else
        register_code = 2; // accumulator

    return register_code.?;
}

// This is an auxiliary function of parseCondition(), it return null on error
fn parseConditionNameHere(parser: *Parser) ?u8 {
    const in = &parser.line_in;
    parser.skipWhitespace();

    const reg = parseConditionRegisterHere(parser);

    var invert: u1 = 0;
    if (std.ascii.toUpper(in.c orelse 0) == 'N') {
        invert = 1;
        in.next();
    }

    if (std.ascii.toUpper(in.c orelse 0) == 'Z')
        in.next()
    else
        return null;

    return invert + reg * 2;
}

pub fn parseCondition(parser: *Parser) !u8 {
    const in = &parser.line_in;
    parser.skipWhitespace();
    const pos = in.current_pos_number;

    if (parseConditionNameHere(parser)) |condition_code|
        return condition_code
    else
        return parser.raiseError(pos, "bad condition name", .{});
}
