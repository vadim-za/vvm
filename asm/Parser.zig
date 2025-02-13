const std = @import("std");
const SourceInput = @import("SourceInput.zig");
const PassOutput = @import("PassOutput.zig");
const LineInput = @import("LineInput.zig");
const Label = @import("Label.zig");
const Labels = @import("Labels.zig");
const commands = @import("commands.zig");

source_in: *SourceInput,
line_in: LineInput,
current_line_number: usize,
labels: Labels,

pub fn init(alloc: std.mem.Allocator, source_in: *SourceInput) @This() {
    const line_in: LineInput = .init(source_in);
    return .{
        .source_in = source_in,
        .line_in = line_in,
        .current_line_number = 1,
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

    if (!in.isAtWhitespace()) {
        if (try self.tryParseCommentHere())
            return;
        try self.parseLabelDefinitionHere();
    }

    self.skipWhitespace();
    if (in.c == null)
        return; // no command

    if (try self.tryParseCommentHere())
        return;
    try self.parseCommandHere(out);

    self.skipWhitespace();
    if (try self.tryParseCommentHere())
        return;

    if (in.c != null)
        return self.raiseError(
            in.current_pos_number,
            "end of line expected",
            .{},
        );
}

fn tryParseCommentHere(self: *@This()) !bool {
    const in = &self.line_in;
    if (in.c != ';')
        return false;

    while (in.c != null)
        in.next();

    return true;
}

pub fn skipWhitespace(self: *@This()) void {
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

pub const parseRegisterName =
    @import("parser/register.zig").parseRegisterName;

pub const parseCondition =
    @import("parser/condition.zig").parseCondition;

pub const parseConstantExpression =
    @import("parser/expression.zig").parseConstantExpression;

const parseLabelDefinitionHere =
    @import("parser/label.zig").parseLabelDefinitionHere;

const parseCommandHere =
    @import("parser/command.zig").parseCommandHere;

pub fn raiseError(
    self: *@This(),
    pos: usize,
    comptime fmt: []const u8,
    args: anytype,
) error{SyntaxError} {
    return self.raiseErrorAtLine(
        self.current_line_number,
        pos,
        fmt,
        args,
    );
}

pub fn raiseErrorAtLine(
    self: *@This(),
    line: usize,
    pos: usize,
    comptime fmt: []const u8,
    args: anytype,
) error{SyntaxError} {
    _ = self;
    std.debug.print(
        "({}:{}) " ++ fmt ++ "\n",
        .{
            line,
            pos,
        } ++ args,
    );
    return error.SyntaxError;
}
