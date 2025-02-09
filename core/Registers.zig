// VVM register file
// See the architectural documentation for details

const std = @import("std");

// VVM uses little endian.
// Due to unknown host endianess we cannot alias values of different sizes,
// therefore we choose u8 as the fundamental type and provide access helper
// functions ('init' and 'as') for larger sizes.

gp: extern union { // general purpose registers Bn/Wn
    b: [8]u8, // aliasing the fundamental type (byte) is okay
    w: [4]WordRegister,
},
pc: u16,
sp: u16,
addr: u16,
a: Accumulators,

pub const WordRegister = extern struct {
    b: [2]u8,

    pub fn initWord(word: u16) @This() {
        return @bitCast(std.mem.nativeToLittle(u16, word));
    }

    pub fn asWord(self: @This()) u16 {
        return std.mem.littleToNative(
            u16,
            @bitCast(self),
        );
    }
};

const Accumulators = extern union {
    w: [2]WordRegister,
    b: [2]u8, // aliasing the bytes is okay, we also need only the first 2

    pub fn initDword(dword: u32) @This() {
        return @bitCast(std.mem.nativeToLittle(u32, dword));
    }

    pub fn asDword(self: @This()) u32 {
        return std.mem.littleToNative(
            u32,
            @bitCast(self),
        );
    }
};
