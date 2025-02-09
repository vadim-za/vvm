// Binary Integer Dichotomy
// Split the binary unsigned integers into the upper and lower halves and back.

const std = @import("std");

pub fn Half(T: type) type {
    const ti = @typeInfo(T).int;
    if (ti.signedness != .unsigned)
        @compileError("Unsigned integer type expected, found " ++ @typeName(T));

    return @Type(.{
        .int = .{
            .signedness = .unsigned,
            .bits = @divExact(ti.bits, 2),
        },
    });
}

test "Half" {
    if (Half(u16) != u8)
        @compileError("Incorrect result");
}

pub fn Double(T: type) type {
    const ti = @typeInfo(T).int;
    if (ti.signedness != .unsigned)
        @compileError("Unsigned integer type expected, found " ++ @typeName(T));

    return @Type(.{
        .int = .{
            .signedness = .unsigned,
            .bits = ti.bits * 2,
        },
    });
}

test "Double" {
    if (Double(u8) != u16)
        @compileError("Incorrect result");
}

pub fn loHalf(value: anytype) Half(@TypeOf(value)) {
    return @truncate(value);
}

test "loHalf" {
    const result = loHalf(@as(u16, 0xABCD));
    if (@TypeOf(result) != u8)
        @compileError("Incorrect result type");
    try std.testing.expectEqual(0xCD, result);
}

pub fn hiHalf(value: anytype) Half(@TypeOf(value)) {
    const T = @TypeOf(value);
    const bits = @typeInfo(T).int.bits;
    return @intCast(value >> @divExact(bits, 2));
}

test "hiHalf" {
    const result = hiHalf(@as(u16, 0xABCD));
    if (@TypeOf(result) != u8)
        @compileError("Incorrect result type");
    try std.testing.expectEqual(0xAB, result);
}

pub fn combine(hi_half: anytype, lo_half: anytype) Double(@TypeOf(lo_half)) {
    const TH = @TypeOf(hi_half);
    const TL = @TypeOf(lo_half);
    if (TH != TL)
        @compileError("Cannot combine halves of different types");
    const D = Double(TL);
    const bits = @typeInfo(TL).int.bits;
    return lo_half | @as(D, hi_half) << bits;
}

test "combine" {
    const result = combine(@as(u8, 0xAB), @as(u8, 0xCD));
    if (@TypeOf(result) != u16)
        @compileError("Incorrect result type");
    try std.testing.expectEqual(0xABCD, result);
}
