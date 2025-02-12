const std = @import("std");
const SourceInput = @import("SourceInput.zig");
const LineInput = @import("LineInput.zig");
const PassOutput = @import("PassOutput.zig");
const Label = @import("Label.zig");
const Command = @import("Command.zig");

source_in: *SourceInput,
line_in: LineInput,
current_line_number: usize,
current_pos_number: usize,
labels: std.ArrayList(Label),

pub fn init(alloc: std.mem.Allocator, source_in: *SourceInput) @This() {
    const line_in: LineInput = .init(source_in);
    return .{
        .source_in = source_in,
        .line_in = line_in,
        .current_line_number = 1,
        .current_pos_number = line_in.current_pos_number,
        .labels = .init(alloc),
    };
}

pub fn deinit(self: *const @This()) void {
    self.labels.deinit();
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
        try self.parseLabel();

    self.skipWhitespace();
    if (in.c == null)
        return; // no command

    try Command.translate(self, out);
}

fn parseLabel(self: *@This()) !void {
    const in = &self.line_in;
    var id_bytes: std.BoundedArray(u8, Label.max_length) = .{};

    if (!in.isAtAlphabetic())
        return self.raiseError("Label must begin with a letter", .{});

    id_bytes.append(in.c.?) catch unreachable; // there must be always space for one character
    in.next();

    while (in.isAtAlphanumeric()) {
        id_bytes.append(in.c.?) catch
            return self.raiseError(
            "label too long (max length = {})",
            .{Label.max_length},
        );
        in.next();
    }

    self.skipWhitespace();

    if (in.c != ':')
        return self.raiseError("label must be followed by a colon", .{});
    self.nextAndUpdatePos();

    const label = Label.init(
        id_bytes.constSlice(),
        self.current_line_number,
    );
    try self.labels.append(label);
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

pub fn parseByteRegisterName(self: *@This()) !u8 {
    const in = &self.line_in;
    self.skipWhitespace();
    if (!in.isAtUpper('B'))
        return self.raiseError("expected byte register name 'Bn'", .{});
    self.nextAndUpdatePos();

    if (!in.isAtDigit())
        return self.raiseError("digit expected", .{});
    self.nextAndUpdatePos();

    const n: u8 = in.c.? - '0';

    if (n >= 8)
        return self.raiseError(
            "byte register index must be between 0 and 7",
            .{},
        );

    return @intCast(n);
}

pub fn parseWordRegisterName(self: *@This()) !u8 {
    const in = &self.line_in;
    self.skipWhitespace();
    if (!in.isAtUpper('W'))
        return self.raiseError("expected word register name 'Wn'", .{});
    self.nextAndUpdatePos();

    if (!in.isAtDigit())
        return self.raiseError("digit expected", .{});
    self.nextAndUpdatePos();

    const n: u8 = in.c.? - '0';

    if (n >= 8)
        return self.raiseError(
            "byte register index must be between 0 and 7",
            .{},
        );

    return @intCast(n);
}

pub fn raiseError(self: *@This(), comptime fmt: []const u8, args: anytype) !void {
    std.debug.print(
        "({}:{}) " ++ fmt ++ "\n",
        .{
            self.current_line_number,
            self.current_pos_number,
        } ++ args,
    );
    return error.SyntaxError;
}
