const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("SDL_image", .{});

    const lib = b.addLibrary(.{
        .name = "SDL3_image",
        .version = .{ .major = 3, .minor = 2, .patch = 0 },
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    const sdl = b.dependency("SDL", .{
        .target = target,
        .optimize = optimize,
    }).artifact("SDL3");
    lib.linkLibrary(sdl);

    // Use stb_image for loading JPEG and PNG files. Native alternatives such as
    // Windows Imaging Component and Apple's Image I/O framework are not yet
    // supported by this build script.
    lib.root_module.addCMacro("USE_STBIMAGE", "");

    // The following are options for supported file formats. AVIF, JXL, TIFF,
    // and WebP are not yet supported by this build script, as they require
    // additional dependencies.
    if (b.option(bool, "enable-bmp", "Support loading BMP images") orelse true)
        lib.root_module.addCMacro("LOAD_BMP", "");
    if (b.option(bool, "enable-gif", "Support loading GIF images") orelse true)
        lib.root_module.addCMacro("LOAD_GIF", "");
    if (b.option(bool, "enable-jpg", "Support loading JPEG images") orelse true)
        lib.root_module.addCMacro("LOAD_JPG", "");
    if (b.option(bool, "enable-lbm", "Support loading LBM images") orelse true)
        lib.root_module.addCMacro("LOAD_LBM", "");
    if (b.option(bool, "enable-pcx", "Support loading PCX images") orelse true)
        lib.root_module.addCMacro("LOAD_PCX", "");
    if (b.option(bool, "enable-png", "Support loading PNG images") orelse true)
        lib.root_module.addCMacro("LOAD_PNG", "");
    if (b.option(bool, "enable-pnm", "Support loading PNM images") orelse true)
        lib.root_module.addCMacro("LOAD_PNM", "");
    if (b.option(bool, "enable-qoi", "Support loading QOI images") orelse true)
        lib.root_module.addCMacro("LOAD_QOI", "");
    if (b.option(bool, "enable-svg", "Support loading SVG images") orelse true)
        lib.root_module.addCMacro("LOAD_SVG", "");
    if (b.option(bool, "enable-tga", "Support loading TGA images") orelse true)
        lib.root_module.addCMacro("LOAD_TGA", "");
    if (b.option(bool, "enable-xcf", "Support loading XCF images") orelse true)
        lib.root_module.addCMacro("LOAD_XCF", "");
    if (b.option(bool, "enable-xpm", "Support loading XPM images") orelse true)
        lib.root_module.addCMacro("LOAD_XPM", "");
    if (b.option(bool, "enable-xv", "Support loading XV images") orelse true)
        lib.root_module.addCMacro("LOAD_XV", "");

    lib.addIncludePath(upstream.path("include"));
    lib.addIncludePath(upstream.path("src"));

    lib.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = srcs,
    });

    if (target.result.os.tag == .macos) {
        lib.addCSourceFile(.{
            .file = upstream.path("src/IMG_ImageIO.m"),
        });
        lib.linkFramework("Foundation");
        lib.linkFramework("ApplicationServices");
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
