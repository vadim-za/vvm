const std = @import("std");
const SourceInput = @import("SourceInput.zig");
const PassOutput = @import("PassOutput.zig");
const LineInput = @import("parser/LineInput.zig");
const Label = @import("parser/Label.zig");
const Command = @import("Command.zig");
const commands = @import("commands.zig");

source_in: *SourceInput,
line_in: LineInput,
current_line_number: usize,
label_table: std.ArrayList(Label),
sorted_labels: ?*[]const Label,

pub fn init(alloc: std.mem.Allocator, source_in: *SourceInput) @This() {
    const line_in: LineInput = .init(source_in);
    return .{
        .source_in = source_in,
        .line_in = line_in,
        .current_line_number = 1,
        .label_table = .init(alloc),
        .sorted_labels = null,
    };
}

pub fn deinit(self: *const @This()) void {
    self.label_table.deinit();
}

pub const Error = error{ SyntaxError, OutOfMemory };

pub fn translate(self: *@This(), out: *PassOutput) Error!void {
    if (try self.parseLine(out) == null)
        return;
    self.current_line_number += 1;
}

fn parseLine(self: *@This(), out: *PassOutput) !?void {
    const in = &self.line_in;
    if (in.c == null)
        return null;

    if (!in.isAtWhitespace())
        try self.parseLabelDefinitionHere();

    self.skipWhitespace();
    if (in.c == null)
        return; // no command

    try self.parseCommandHere(out);
}

fn skipWhitespace(self: *@This()) void {
    const in = &self.line_in;
    while (in.isAtWhitespace())
        in.next();
}

pub fn parseOptionallyWhitespacedComma(self: *@This()) !void {
    const in = &self.line_in;
    self.skipWhitespace();

    const pos = in.current_pos_number;
    if (in.c == ',')
        in.next()
    else
        return self.raiseError(pos, "comma expected", .{});

    self.skipWhitespace();
}

pub fn parseRegisterName(
    self: *@This(),
    prefix_uppercase_char: u8,
    kind: []const u8,
    total_number: u8,
) !u8 {
    const in = &self.line_in;
    self.skipWhitespace();

    {
        const pos = in.current_pos_number;
        if (in.isAtUpper(prefix_uppercase_char))
            in.next()
        else
            return self.raiseError(
                pos,
                "expected {s} register name '{c}n'",
                .{ kind, prefix_uppercase_char },
            );
    }

    const pos = in.current_pos_number;

    if (in.isAtDigit())
        in.next()
    else
        return self.raiseError(pos, "digit expected", .{});

    const n: u8 = in.c.? - '0';

    if (n >= total_number)
        return self.raiseError(
            pos,
            "byte register index must be between 0 and {}",
            .{total_number},
        );

    return @intCast(n);
}

// This function always succeeds, since condition register may be empty
fn parseConditionRegisterHere(self: *@This()) u8 {
    const in = &self.line_in;

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
fn parseConditionNameHere(self: *@This()) ?u8 {
    const in = &self.line_in;
    self.skipWhitespace();

    const reg = self.parseConditionRegisterHere();

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

pub fn parseCondition(self: *@This()) !u8 {
    const in = &self.line_in;
    self.skipWhitespace();
    const pos = in.current_pos_number;

    if (self.parseConditionNameHere()) |condition_code|
        return condition_code
    else
        return self.raiseError(pos, "bad condition name", .{});
}

fn tryParseUnsignedDecimalHere(self: *@This(), T: type) !?T {
    const in = &self.line_in;

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

fn tryParseUnsignedHexHere(self: *@This(), T: type) !?T {
    const in = &self.line_in;

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
        self.raiseError(pos, "bad hexadecimal number", .{});
}

fn tryParseLabelAsValueHere(self: *@This(), T: type) !?T {
    const name = (try self.tryParseLabelNameHere()) orelse return null;
    _ = name; // autofix
    if (self.sorted_labels) |labels| {
        _ = labels; // autofix
        unreachable; // todo
    }
    return 0;
}

fn parseUnsignedConstantTermHere(self: *@This(), T: type) !T {
    const in = &self.line_in;
    const pos = in.current_pos_number;

    if (try self.tryParseUnsignedDecimalHere(T)) |value|
        return value;

    if (try self.tryParseUnsignedHexHere(T)) |value|
        return value;

    if (try self.tryParseLabelAsValueHere(T)) |value|
        return value;

    return self.raiseError(pos, "a number or a label is expected", .{});
}

fn parseConstantTerm(self: *@This(), T: type) !T {
    const in = &self.line_in;
    self.skipWhitespace();

    var negate: ?bool = null;
    switch (in.c orelse 0) {
        '+' => negate = false,
        '-' => negate = true,
        else => {},
    }

    if (negate != null) {
        in.next();
        self.skipWhitespace();
    } else negate = false;

    const value = try self.parseUnsignedConstantTermHere(T);
    return if (negate.?) 0 -| value else value;
}

pub fn parseConstantExpression(self: *@This(), T: type) !T {
    const in = &self.line_in;

    var sum = try self.parseConstantTerm(T);
    while (true) {
        self.skipWhitespace();
        switch (in.c orelse 0) {
            '+' => sum +|= try self.parseConstantTerm(T),
            '-' => sum -|= try self.parseConstantTerm(T),
            else => break,
        }
    }

    return sum;
}

fn tryParseLabelNameHere(self: *@This()) !?Label.Name {
    const in = &self.line_in;
    const pos = in.current_pos_number;

    if (!in.isAtAlphabetic())
        return null;

    var name: std.BoundedArray(u8, Label.max_length) = .{};
    while (in.isAtAlphanumeric()) {
        name.append(in.c.?) catch
            return self.raiseError(
            pos,
            "label too long (max length = {})",
            .{Label.max_length},
        );
        in.next();
    }

    return Label.initName(name.constSlice());
}

fn parseLabelDefinitionHere(self: *@This()) !void {
    const in = &self.line_in;
    const pos = in.current_pos_number;

    const name = (try self.tryParseLabelNameHere()) orelse
        return self.raiseError(pos, "label expected", .{});
    self.skipWhitespace();

    const pos_after_label = in.current_pos_number;
    if (in.c == ':')
        in.next()
    else
        return self.raiseError(
            pos_after_label,
            "label must be followed by a colon",
            .{},
        );

    const label = Label.init(
        name,
        self.current_line_number,
    );
    try self.label_table.append(label);
}

fn parseCommandHere(self: *@This(), out: *PassOutput) !void {
    const in = &self.line_in;
    const pos = in.current_pos_number;

    const max_name = 8;
    var name_bytes: std.BoundedArray(u8, max_name) = .{};

    if (!in.isAtAlphabetic())
        return self.raiseError(
            pos,
            "instruction name must begin with a letter",
            .{},
        );

    while (in.isAtAlphabetic()) {
        name_bytes.append(in.c.?) catch
            return self.raiseError(
            pos,
            "instruction name too long (max length = {})",
            .{max_name},
        );
        in.next();
    }

    if (!in.isAtWhitespaceOrEol())
        return self.raiseError(pos, "bad instruction name", .{});

    const name = name_bytes.slice();
    _ = std.ascii.upperString(name, name);
    const command = commands.findUppercase(name) orelse
        return self.raiseError(
        pos,
        "unknown instruction name '{s}'",
        .{name},
    );

    self.skipWhitespace();
    try command.translate(self, out);
    self.skipWhitespace();

    const pos_after_command = in.current_pos_number;
    if (in.c != null)
        return self.raiseError(
            pos_after_command,
            "end of line expected",
            .{},
        );
}

pub fn raiseError(
    self: *@This(),
    pos: usize,
    comptime fmt: []const u8,
    args: anytype,
) error{SyntaxError} {
    std.debug.print(
        "({}:{}) " ++ fmt ++ "\n",
        .{
            self.current_line_number,
            pos,
        } ++ args,
    );
    return error.SyntaxError;
}
