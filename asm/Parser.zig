const std = @import("std");
const SourceInput = @import("SourceInput.zig");
const LineInput = @import("LineInput.zig");
const PassOutput = @import("PassOutput.zig");
const Label = @import("Label.zig");
const Command = @import("Command.zig");
const commands = @import("commands.zig");

source_in: *SourceInput,
line_in: LineInput,
current_line_number: usize,
current_pos_number: usize,
label_table: std.ArrayList(Label),
sorted_labels: ?*[]const Label,

pub fn init(alloc: std.mem.Allocator, source_in: *SourceInput) @This() {
    const line_in: LineInput = .init(source_in);
    return .{
        .source_in = source_in,
        .line_in = line_in,
        .current_line_number = 1,
        .current_pos_number = line_in.current_pos_number,
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

    self.current_pos_number = in.current_pos_number;
    if (!in.isAtWhitespace())
        try self.parseLabelDefinitionHere();

    self.skipWhitespace();
    if (in.c == null)
        return; // no command

    try self.parseCommandHere(out);
}

fn nextAndUpdatePos(self: *@This()) void {
    const in = &self.line_in;
    in.next();
    self.current_pos_number = in.current_pos_number;
}

fn skipWhitespace(self: *@This()) void {
    const in = &self.line_in;
    while (in.isAtWhitespace())
        self.nextAndUpdatePos();
}

pub fn parseOptionallyWhitespacedComma(self: *@This()) !void {
    const in = &self.line_in;
    self.skipWhitespace();
    if (in.c != ',')
        return self.raiseError("comma expected", .{});
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

    if (!in.isAtUpper(prefix_uppercase_char))
        return self.raiseError(
            "expected {s} register name '{c}n'",
            .{ kind, prefix_uppercase_char },
        );
    self.nextAndUpdatePos();

    if (!in.isAtDigit())
        return self.raiseError("digit expected", .{});
    self.nextAndUpdatePos();

    const n: u8 = in.c.? - '0';

    if (n >= total_number)
        return self.raiseError(
            "byte register index must be between 0 and {}",
            .{total_number},
        );

    return @intCast(n);
}

pub fn parseCondition(self: *@This()) !u8 {
    const in = &self.line_in;
    self.skipWhitespace();

    var invert: u8 = 0;

    if (in.c == null)
        return self.raiseError("condition name expected", .{});

    var register_code: ?u8 =
        switch (std.ascii.toUpper(in.c.?)) {
        'H' => 1,
        'L' => 0,
        'X' => 3,
        else => null,
    };
    if (register_code != null)
        in.next()
    else
        register_code = 2; // accumulator

    if (in.c == null)
        return self.raiseError("condition name expected", .{});

    if (std.ascii.toUpper(in.c.?) == 'N') {
        invert = 1;
        in.next();
    }

    if (in.c == null or std.ascii.toUpper(in.c.?) != 'Z')
        return self.raiseError("condition name expected", .{});
    self.nextAndUpdatePos();

    return invert + register_code.? * 2;
}

fn parseUnsignedNumberHere(self: *@This(), T: type) !T {
    const in = &self.line_in;

    var value: T = 0;
    var digit_count: usize = 0;

    while (in.c == '0') : (digit_count += 1)
        in.next();

    var is_hex = false;
    if (digit_count == 1 and in.c == 'x') {
        is_hex = true;
        digit_count = 0; // reset
        in.next();
    }
    const base: T = if (is_hex) 16 else 10;

    while (in.c) |c| : (digit_count += 1) {
        switch (std.ascii.toUpper(c)) {
            '0'...'9' => value = value *| base +| (c - '0'),
            'A'...'F' => value = value *| base +| ((c - 'A') + 10),
            else => {
                if (digit_count == 0)
                    return self.raiseError("digit expected", .{})
                else
                    break;
            },
        }
        in.next();
    }

    return value;
}

fn parseLabelAsValueHere(self: *@This(), T: type) !T {
    const name = try self.parseLabelNameHere();
    _ = name; // autofix
    if (self.sorted_labels) |labels| {
        _ = labels; // autofix
        unreachable; // todo
    }
    return 0;
}

fn parseConstantTermWithoutSignHere(self: *@This(), T: type) !T {
    const in = &self.line_in;

    if (in.isAtDigit())
        return self.parseUnsignedNumberHere(T);

    if (in.isAtAlphabetic())
        return self.parseLabelAsValueHere(T);

    return self.raiseError("unexpected character", .{});
}

fn parseConstantTerm(self: *@This(), T: type) !T {
    const in = &self.line_in;
    self.skipWhitespace();

    var sign: T = 1;
    while (in.c) |c| {
        switch (c) {
            '+' => {},
            '-' => sign = 0 -| sign,
            else => break,
        }
        self.nextAndUpdatePos();
        self.skipWhitespace();
    }

    const unsigned = try self.parseConstantTermWithoutSignHere(T);
    return unsigned *| sign;
}

pub fn parseConstantExpression(self: *@This(), T: type) !T {
    const in = &self.line_in;

    var sum = try self.parseConstantTerm(T);
    while (true) {
        self.skipWhitespace();
        if (in.c) |c| switch (c) {
            '+' => sum +|= try self.parseConstantTerm(T),
            '-' => sum -|= try self.parseConstantTerm(T),
            else => return sum,
        } else return sum;
    }
}

fn parseLabelNameHere(self: *@This()) !Label.Name {
    const in = &self.line_in;
    var name: std.BoundedArray(u8, Label.max_length) = .{};

    if (!in.isAtAlphabetic())
        return self.raiseError("Label must begin with a letter", .{});

    name.append(in.c.?) catch unreachable; // there must be always space for one character
    in.next();

    while (in.isAtAlphanumeric()) {
        name.append(in.c.?) catch
            return self.raiseError(
            "label too long (max length = {})",
            .{Label.max_length},
        );
        in.next();
    }

    return Label.initName(name.constSlice());
}

fn parseLabelDefinitionHere(self: *@This()) !void {
    const in = &self.line_in;

    const name = try self.parseLabelNameHere();
    self.skipWhitespace();

    if (in.c != ':')
        return self.raiseError("label must be followed by a colon", .{});
    self.nextAndUpdatePos();

    const label = Label.init(
        name,
        self.current_line_number,
    );
    try self.label_table.append(label);
}

fn parseCommandHere(self: *@This(), out: *PassOutput) !void {
    const in = &self.line_in;
    const max_name = 8;
    var name_bytes: std.BoundedArray(u8, max_name) = .{};

    if (!in.isAtAlphabetic())
        return self.raiseError(
            "instruction name must begin with a letter",
            .{},
        );

    name_bytes.append(in.c.?) catch unreachable; // there must be always space for one character
    in.next();

    while (in.isAtAlphabetic()) {
        name_bytes.append(in.c.?) catch
            return self.raiseError(
            "instruction name too long (max length = {})",
            .{max_name},
        );
        in.next();
    }

    if (!in.isAtWhitespaceOrEol())
        return self.raiseError("bad instruction name", .{});

    const name = name_bytes.slice();
    _ = std.ascii.upperString(name, name);
    const command = commands.findUppercase(name) orelse
        return self.raiseError(
        "unknown instruction name '{s}'",
        .{name},
    );

    self.skipWhitespace();
    try command.translate(self, out);
    self.skipWhitespace();

    if (in.c != null)
        return self.raiseError("end of line expected", .{});
}

pub fn raiseError(
    self: *@This(),
    comptime fmt: []const u8,
    args: anytype,
) error{SyntaxError} {
    std.debug.print(
        "({}:{}) " ++ fmt ++ "\n",
        .{
            self.current_line_number,
            self.current_pos_number,
        } ++ args,
    );
    return error.SyntaxError;
}
