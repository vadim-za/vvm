// VVM register file
// See the architectural documentation for details

const bid = @import("bid.zig");

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

const WordRegister = extern struct {
    b: [2]u8,

    pub fn initWord(word: u16) @This() {
        return .{
            .b = .{
                bid.loHalf(word),
                bid.hiHalf(word),
            },
        };
    }

    pub fn asWord(self: *@This()) u16 {
        return bid.combine(
            self.b[1],
            self.b[0],
        );
    }
};

const Accumulators = extern union {
    w: [2]WordRegister,
    b: [2]u8, // aliasing the bytes is okay, we also need only the first 2

    pub fn initDword(dword: u32) @This() {
        return .{
            .w = .{
                .initWord(bid.loHalf(dword)),
                .initWord(bid.hiHalf(dword)),
            },
        };
    }

    pub fn asDword(self: *@This()) u16 {
        return bid.combine(
            self.w[1].asWord(),
            self.w[0].asWord(),
        );
    }
};
