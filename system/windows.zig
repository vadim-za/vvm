const std = @import("std");

extern "kernel32" fn ReadConsoleInputExW(
    hConsoleInput: std.os.windows.HANDLE,
    lpBuffer: [*]INPUT_RECORD,
    nLength: std.os.windows.DWORD,
    lpNumberOfEventsRead: *std.os.windows.DWORD,
    uFlags: std.os.windows.USHORT,
) callconv(std.os.windows.WINAPI) std.os.windows.BOOL;

const INPUT_RECORD = extern struct {
    EventType: std.os.windows.WORD,
    Event: extern union {
        KeyEvent: KEY_EVENT_RECORD,
        // Omit other fields, as we do not need them for now
    },
};

const KEY_EVENT_RECORD = extern struct {
    bKeyDown: std.os.windows.BOOL,
    wRepeatCount: std.os.windows.WORD,
    wVirtualKeyCode: std.os.windows.WORD,
    wVirtualScanCode: std.os.windows.WORD,
    uChar: extern union {
        UnicodeChar: std.os.windows.WCHAR,
        AsciiChar: std.os.windows.CHAR,
    },
    dwControlKeyState: std.os.windows.DWORD,
};

var hStdIn: ?std.os.windows.HANDLE = null;

// Zero return value means no input or unrecognized input
pub fn getKeyboardInput(wait: bool) u8 {
    // Acquire hStdIn
    if (hStdIn == null) {
        if (std.os.windows.GetStdHandle(std.os.windows.STD_INPUT_HANDLE)) |h|
            hStdIn = h
        else |_| {}
    }

    const hIn = if (hStdIn) |h| h else return 0;

    var record: INPUT_RECORD = undefined;
    var numEventsRead: std.os.windows.DWORD = 0;
    if (ReadConsoleInputExW(
        hIn,
        @as(*[1]INPUT_RECORD, &record),
        1,
        &numEventsRead,
        if (wait) 0 else 2, // CONSOLE_READ_NOWAIT=2
    ) == 0)
        return 0;
    if (numEventsRead == 0)
        return 0;

    return switch (record.EventType) {
        1 => { // KEY_EVENT
            const ke = &record.Event.KeyEvent;
            if (ke.bKeyDown == 0)
                return 0;
            return if (ke.uChar.UnicodeChar >= 0x20 and ke.uChar.UnicodeChar <= 0x7F)
                @as(u8, @truncate(ke.uChar.UnicodeChar))
            else
                0;
        },
        else => 0,
    };
}
