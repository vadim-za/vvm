This file documents the features of the standard environment included into the [virtual system](system/).

The virtual system provides the command line tool containing the cross-assembler and the core virtual system, connected to the virtual environment. The virtual environment provides the I/O connectivity to the core system via the port input/output operations accessible via the `IN` and `OUT` assembler commands.

## Output ports

### Port 0: CPU control

| Value | Command semantics |
| ----- | ----------------- |
| 0 | Halt the CPU and exit the emulator. This value is reserved by the system itself and cannot be redefined by custom environments |
| 1 | Run the CPU. This value has no use if written by a virtual program, since the program must be already running in order to write to the ports, but this value's semantics is equally reserved by the system |
| 2 | Halt the CPU until the timer elapses (see [Timer control](#port-3-timer-control)) |

### Port 1: Console output

Byte values written to this port are sent to the console output (stdout). The standard environment will attempt to support ANSI escape sequences.

### Port 2: Keyboard control

| Value | Command semantics |
| ----- | ----------------- |
| 0 | default keyboard mode (buffered input, waiting for newline) |
| 1 | realtime keyboard mode (see [Console input](#port-1-console-input)) |

The realtime keyboard mode is currently only supported on Windows. Feel free to provide support for other operating systems in your own derived projects, which can be done by putting more files into [`keyboard_support` folder](system/keyboard_support) and adjusting the `keyboard_support` decl at the top of [`Environment.zig`](system/Environment.zig) or your own environment file.

### Port 3: Timer control

The byte values written to this port set the timeout values in 4ms units. Upon the "wait command" (value 2 sent to port 0) the timer will wait until the given timeout elapses. The timeout is measured from the previous wait completion.

NB. This is not a countdown, the time is literally being measured from the previous "event". This is done to make it easier to hold (approximately) constant intervals between the "events", irregardless of how long it took from the previous "event" until the new "wait command".

NB. Use a 0 timeout (combined with the "wait command") to "reset" the timer, so that the timer "starts counting from scratch" (making it behave similarly to a `delay()` function this time).

## Input ports

### Port 0: Currently unused

### Port 1: Console input

The byte values read from this port correspond to the contents of the console input (stdin). In the default mode the input is buffered and waits for the newline. The `IN` command on this port will respectively halt the virtual processor until some input is available.

Some host environments (currently Windows) also support realtime mode, where the `IN` command will return zero if there is nothing in the buffer (without halting the processor).

### Port 2: Keyboard mode

The value read from this port indicates whether realtime keyboard mode has been successfully set (lowest significant bit is set) or not (lowest significant bit is reset). Other bits of the value are reserved for the future and should not be checked.

## Readonly memory

The environment can declare an address range at the top of the addressable space as readonly, by setting the `rom_addr` field in the `core` member of the `System` object that it is connected to. It's probably easiest to do that inside the environment's `init` function.

## Custom environments

As mentioned elsewhere in this docs, feel free to implement your own virtual environments. It's best to put your environment file alongside the existing [system/Environment.zig](system/Environment.zig), this way you'd minimize potential conflicts upon updating from the upstream.

You can implement further I/O functionality in your own environment, however please use ports 0x80-0xFF for that. Lower port indices might get further standard functionality, which you probably don't want to conflict with.