// This is a connector to the system's "environment" part.
// Don't set the fields yourself, use the init() function.

ptr: ?*anyopaque,
vft: struct {
    in: *const fn (ptr: ?*anyopaque, port: u8) u8,
    out: *const fn (ptr: ?*anyopaque, port: u8, value: u8) void,
},

// Construct the environment connector, supplying the actual
// environment type T and the pointer to the actual environment
// object (or you may pass null for stateless environments).
// The environment type T needs to implement a number of standard
// environment methods, to which the 'vft' field will connect itself.
pub fn init(T: type, ptr: ?*T) @This() {
    return .{
        .ptr = ptr,
        .vft = .{
            .in = T.envIn,
            .out = T.envOut,
        },
    };
}

// Default environment, which is not connected to anything
pub const default = @This().init(Default, null);

const Default = struct {
    fn envIn(_: ?*anyopaque, _: u8) u8 {
        return 0;
    }
    fn envOut(_: ?*anyopaque, _: u8, _: u8) void {}
};
