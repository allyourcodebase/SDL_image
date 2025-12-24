const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const sanitize_c_type = @typeInfo(@FieldType(std.Build.Module.CreateOptions, "sanitize_c")).optional.child;
    const sanitize_c = b.option(sanitize_c_type, "sanitize-c", "Detect undefined behavior in C");

    const upstream = b.dependency("SDL_image", .{});

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .sanitize_c = sanitize_c,
    });

    const lib = b.addLibrary(.{
        .name = "SDL3_image",
        .version = .{ .major = 3, .minor = 2, .patch = 0 },
        .linkage = .static,
        .root_module = mod,
    });

    const sdl = b.dependency("SDL", .{
        .target = target,
        .optimize = optimize,
    }).artifact("SDL3");
    mod.linkLibrary(sdl);

    // Use stb_image for loading JPEG and PNG files. Native alternatives such as
    // Windows Imaging Component and Apple's Image I/O framework are not yet
    // supported by this build script.
    mod.addCMacro("USE_STBIMAGE", "");

    // The following are options for supported file formats. AVIF, JXL, TIFF,
    // and WebP are not yet supported by this build script, as they require
    // additional dependencies.
    if (b.option(bool, "enable-bmp", "Support loading BMP images") orelse true)
        mod.addCMacro("LOAD_BMP", "");
    if (b.option(bool, "enable-gif", "Support loading GIF images") orelse true)
        mod.addCMacro("LOAD_GIF", "");
    if (b.option(bool, "enable-jpg", "Support loading JPEG images") orelse true)
        mod.addCMacro("LOAD_JPG", "");
    if (b.option(bool, "enable-lbm", "Support loading LBM images") orelse true)
        mod.addCMacro("LOAD_LBM", "");
    if (b.option(bool, "enable-pcx", "Support loading PCX images") orelse true)
        mod.addCMacro("LOAD_PCX", "");
    if (b.option(bool, "enable-png", "Support loading PNG images") orelse true)
        mod.addCMacro("LOAD_PNG", "");
    if (b.option(bool, "enable-pnm", "Support loading PNM images") orelse true)
        mod.addCMacro("LOAD_PNM", "");
    if (b.option(bool, "enable-qoi", "Support loading QOI images") orelse true)
        mod.addCMacro("LOAD_QOI", "");
    if (b.option(bool, "enable-svg", "Support loading SVG images") orelse true)
        mod.addCMacro("LOAD_SVG", "");
    if (b.option(bool, "enable-tga", "Support loading TGA images") orelse true)
        mod.addCMacro("LOAD_TGA", "");
    if (b.option(bool, "enable-xcf", "Support loading XCF images") orelse true)
        mod.addCMacro("LOAD_XCF", "");
    if (b.option(bool, "enable-xpm", "Support loading XPM images") orelse true)
        mod.addCMacro("LOAD_XPM", "");
    if (b.option(bool, "enable-xv", "Support loading XV images") orelse true)
        mod.addCMacro("LOAD_XV", "");

    mod.addIncludePath(upstream.path("include"));
    mod.addIncludePath(upstream.path("src"));

    mod.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = srcs,
    });

    if (target.result.os.tag == .macos) {
        mod.addCSourceFile(.{
            .file = upstream.path("src/IMG_ImageIO.m"),
        });
        mod.linkFramework("Foundation", .{});
        mod.linkFramework("ApplicationServices", .{});
    }

    lib.installHeadersDirectory(upstream.path("include"), "", .{});

    b.installArtifact(lib);
}

const srcs: []const []const u8 = &.{
    "IMG.c",
    "IMG_WIC.c",
    "IMG_avif.c",
    "IMG_bmp.c",
    "IMG_gif.c",
    "IMG_jpg.c",
    "IMG_jxl.c",
    "IMG_lbm.c",
    "IMG_pcx.c",
    "IMG_png.c",
    "IMG_pnm.c",
    "IMG_qoi.c",
    "IMG_stb.c",
    "IMG_svg.c",
    "IMG_tga.c",
    "IMG_tif.c",
    "IMG_webp.c",
    "IMG_xcf.c",
    "IMG_xpm.c",
    "IMG_xv.c",
};
