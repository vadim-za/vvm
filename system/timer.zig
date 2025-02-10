const std = @import("std");

pub const SystemTimer = Timer(std.time);

fn Timer(api: type) type {
    return struct {
        timeout_4ms: u8 = 0, // in 4ms units, to be set by user
        prev_timestamp_ms: i64, // in ms

        pub fn init() @This() {
            return .{
                .prev_timestamp_ms = api.milliTimestamp(),
            };
        }

        pub fn wait(self: *@This()) void {
            const time_ms = api.milliTimestamp(); // retrieve exactly once per call!

            const elapsed_ms = time_ms -% self.prev_timestamp_ms;
            const timeout_ms = @as(i64, self.timeout_4ms) * 4;

            // Notice that elapsed_ms can be negative because of sleeps()'s jitter
            if (elapsed_ms < timeout_ms) {
                const wait_ms: u64 = @intCast(timeout_ms - elapsed_ms);

                api.sleep(wait_ms * 1_000_000);
                self.prev_timestamp_ms +%= timeout_ms; // accommodate sleep()'s jitter
            } else {
                self.prev_timestamp_ms = time_ms; // already overtime, reset
            }
        }
    };
}

const test_api = struct {
    var next_milli_timestamp: ?i64 = null;
    var slept_ns: ?u64 = null;

    fn milliTimestamp() i64 {
        const result = next_milli_timestamp.?;
        next_milli_timestamp = null;
        return result;
    }

    fn sleep(nanoseconds: u64) void {
        if (slept_ns != null)
            @panic("Previous sleep() call hasn't been treated yet");

        slept_ns = nanoseconds;
    }
};

test "Test" {
    const TestTimer = Timer(test_api);
    const ms_to_ns = 1_000_000; // conversion factor

    test_api.next_milli_timestamp = 10;
    test_api.slept_ns = null;
    var timer = TestTimer.init();
    try std.testing.expectEqual(10, timer.prev_timestamp_ms);
    try std.testing.expectEqual(null, test_api.next_milli_timestamp); // was queried
    try std.testing.expectEqual(null, test_api.slept_ns); // didn't sleep

    // Wait 0ms at the same time moment
    timer.timeout_4ms = 0;
    test_api.next_milli_timestamp = 10;
    test_api.slept_ns = null;
    timer.wait();
    try std.testing.expectEqual(10, timer.prev_timestamp_ms);
    try std.testing.expectEqual(null, test_api.next_milli_timestamp); // was queried
    try std.testing.expectEqual(null, test_api.slept_ns); // didn't sleep

    // Wait 0ms at a later time moment
    timer.timeout_4ms = 0;
    test_api.next_milli_timestamp = 20;
    test_api.slept_ns = null;
    timer.wait();
    try std.testing.expectEqual(20, timer.prev_timestamp_ms);
    try std.testing.expectEqual(null, test_api.next_milli_timestamp); // was queried
    try std.testing.expectEqual(null, test_api.slept_ns); // didn't sleep

    // Wait 16ms at a slightly later time moment (21ms)
    // which should result in a 15ms sleep
    timer.timeout_4ms = 4;
    test_api.next_milli_timestamp = 21;
    test_api.slept_ns = null;
    timer.wait();
    try std.testing.expectEqual(36, timer.prev_timestamp_ms);
    try std.testing.expectEqual(null, test_api.next_milli_timestamp); // was queried
    try std.testing.expectEqual(15 * ms_to_ns, test_api.slept_ns);

    // Pretend the previous sleep exited 1ms too early (at 35ms instead of 36ms)
    // Ask to wait another 8ms (which should result in a 9ms sleep)
    timer.timeout_4ms = 2;
    test_api.next_milli_timestamp = 35;
    test_api.slept_ns = null;
    timer.wait();
    try std.testing.expectEqual(44, timer.prev_timestamp_ms);
    try std.testing.expectEqual(null, test_api.next_milli_timestamp); // was queried
    try std.testing.expectEqual(9 * ms_to_ns, test_api.slept_ns);

    // Pretend the previous sleep exited way too late (at 60ms instead of 44ms)
    // Wait 0ms, which should update the timer state without sleeping
    timer.timeout_4ms = 0;
    test_api.next_milli_timestamp = 60;
    test_api.slept_ns = null;
    timer.wait();
    try std.testing.expectEqual(60, timer.prev_timestamp_ms);
    try std.testing.expectEqual(null, test_api.next_milli_timestamp); // was queried
    try std.testing.expectEqual(null, test_api.slept_ns);

    // Now let's wait another 8ms, but we start waiting too late (at 70ms aready)
    // This should update the timer state to 70ms
    timer.timeout_4ms = 2;
    test_api.next_milli_timestamp = 70;
    test_api.slept_ns = null;
    timer.wait();
    try std.testing.expectEqual(70, timer.prev_timestamp_ms);
    try std.testing.expectEqual(null, test_api.next_milli_timestamp); // was queried
    try std.testing.expectEqual(null, test_api.slept_ns); // didn't sleep

    // Let's now do another normal sleep starting at 75ms and waiting till 78ms
    // which shoud be achieved by a 8ms formal wait time (as the formal start is at 70ms)
    timer.timeout_4ms = 2;
    test_api.next_milli_timestamp = 75;
    test_api.slept_ns = null;
    timer.wait();
    try std.testing.expectEqual(78, timer.prev_timestamp_ms);
    try std.testing.expectEqual(null, test_api.next_milli_timestamp); // was queried
    try std.testing.expectEqual(3 * ms_to_ns, test_api.slept_ns);

    // Pretend we exited too early again (at 77ms) and wait for 0ms
    // This should result in a 1ms wait
    timer.timeout_4ms = 0;
    test_api.next_milli_timestamp = 77;
    test_api.slept_ns = null;
    timer.wait();
    try std.testing.expectEqual(78, timer.prev_timestamp_ms);
    try std.testing.expectEqual(null, test_api.next_milli_timestamp); // was queried
    try std.testing.expectEqual(1 * ms_to_ns, test_api.slept_ns);
}
