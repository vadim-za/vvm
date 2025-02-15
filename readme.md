# Vintage-like Virtual Machine

## Overview

This is a toy virtual machine project, consisting of
- the virtual machine's core (CPU + memory)
- a virual system (core + virtual hardware)
- a cross-assembler

The machine's architecture has been designed from scratch, taking inspiration from a number of early computer and programmable calculator architectures. It has been deliberately held highly restrictive.

The main goals of the project are
- using it as a playground to work on Zig programming skills
- using it as a playground to refresh/improve certain rusty general programming skills
- try to design an own virtual system (albeit toy-level, this still requires a certain mind- and skill-set)
- possibly using it in workshops dedicated to low-level programming

Further details can be taken from:
- [Instruction set docs](docs/instruction_set.md)
- [Standard environment docs](docs/environment.md)
- [Assembler docs](docs/assembler.md)
- [Assembler examples](asm/examples/)
- [Command line docs](docs/command_line.md)
- [Caterpillar game](asm/examples/caterpillar.vvma) written in the VVM assembler. Use `vvm run caterpillar.vvma` to try (you might need to supply relative paths to the file names and or the `vvm` file's extension) to try. Use `j`, `k`, `l`, `i` keys (lowercase only) to control.

NB. The *caterpillar game* requires the host to support realtime keyboard support which is currently only available on Windows systems. It should be however pretty easy to provide this support on other systems (provided the systems themselves support this input mode). See `keyboard_support` declaration at the top of [system/Environment.zig](system/Environment.zig)

## Building

Nothing special, just your usual `zig build` (with optional arguments). The project is currently being developed against `Zig 0.14.0-dev.2851`.

### .gitignore

There is no `.gitignore` file in the repository. This is currently intentional, as the author's local copy contains some extra response files used for the custom build process, as well as some further files. As it is not possible to have multiple `.gitignore`s within one folder, the current choice is to not commit `.gitignore` to the repository at all. One can also consider using a computer-global `.gitignore` to exclude folders like `.zig-cache` and `zig-out`.

## Contributing

At the moment the project is running in a single-person mode, external PRs will be rejected. However feel free to fork the project and make a derived one. In particular you might wish to extend the environment features, which can be done by writing your own environment file. It's best to put such file alongside the existing [system/Environment.zig](system/Environment.zig), this way you'd minimize potential conflicts upon updating from the upstream.