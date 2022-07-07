const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("zigretro-core", "src/main.zig", b.version(0, 0, 1));
    lib.setBuildMode(mode);

    // Build with Zig 0.9.1
    // Those methods changes if you use a newer version.
    lib.addIncludeDir("src/libretro");
    lib.addSystemIncludeDir("src/mruby/mruby/include");
    lib.addLibPath("src/mruby/mruby/build/host/lib");
    lib.addCSourceFile("src/mruby/mruby_compat.c", &.{});
    lib.addPackagePath("mruby", "src/mruby/mruby.zig");
    lib.linkSystemLibrary("mruby");

    lib.linkLibC();
    lib.install();
}
