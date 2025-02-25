const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const VvmCore = b.createModule(.{
        .root_source_file = b.path("core/Vvm.zig"),
        .target = target,
        .optimize = optimize,
    });

    const core_tests = b.addTest(.{
        .root_source_file = b.path("core/Vvm.zig"),
        .target = target,
        .optimize = optimize,
    });

    const @"asm" = b.createModule(.{
        .root_source_file = b.path("asm/asm.zig"),
        .target = target,
        .optimize = optimize,
    });
    @"asm".addImport("VvmCore", VvmCore);

    const asm_tests = b.addTest(.{
        .root_source_file = b.path("asm/asm.zig"),
        .target = target,
        .optimize = optimize,
    });
    asm_tests.root_module.addImport("VvmCore", VvmCore);

    const system = b.addExecutable(.{
        .name = "vvm",
        .root_source_file = b.path("system/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    system.root_module.addImport("VvmCore", VvmCore);
    system.root_module.addImport("asm", @"asm");
    b.installArtifact(system);

    const system_tests = b.addTest(.{
        .root_source_file = b.path("system/System.zig"),
        .target = target,
        .optimize = optimize,
    });
    system_tests.root_module.addImport("VvmCore", VvmCore);
    system_tests.root_module.addImport("asm", @"asm");

    const run_core_tests = b.addRunArtifact(core_tests);
    const run_asm_tests = b.addRunArtifact(asm_tests);
    const run_system_tests = b.addRunArtifact(system_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_core_tests.step);
    test_step.dependOn(&run_asm_tests.step);
    test_step.dependOn(&run_system_tests.step);
}
