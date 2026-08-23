# SDL_image

This is [SDL_image][1] packaged for [Zig][2].

To use SDL_image along with [SDL][3], do the following in the project you want
them in:

1. zig fetch both projects to save the dependencies to your `build.zig.zon`:
```sh
zig fetch --save git+https://github.com/allyourcodebase/SDL
zig fetch --save git+https://github.com/allyourcodebase/SDL_image
```

2. Then do this in `build.zig`:
```zig
// build.zig
// ...
    const sdl_dep = b.dependency("sdl", .{
        .optimize = optimize,
        .target = target,
    });
    const sdl_lib = sdl_dep.artifact("SDL3");
    exe.root_module.linkLibrary(sdl_lib);

    const sdl_image_dep = b.dependency("SDL_image", .{
        .optimize = optimize,
        .target = target,
    });
    const sdl_image_lib = sdl_image_dep.artifact("SDL3_image");
    exe.root_module.linkLibrary(sdl_image_lib);

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.addWriteFiles().add("stub.h",
            \\#include <SDL3/SDL.h>
            \\#include <SDL3_image/SDL_image.h>
        ),
        .target = target,
        .optimize = optimize,
    });
    translate_c.addIncludePath(sdl_lib.getEmittedIncludeTree());
    translate_c.addIncludePath(sdl_image_lib.getEmittedIncludeTree());
    exe.root_module.addImport("sdl-bundle", translate_c.createModule());
// ...
```

This will bundle SDL and SDL_image in a single module and allow cross-using the
objects between the two libraries.

3. Finally, you can use the two libraries like this in your project:

```zig
const sdl = @import("sdl-bundle");

const surface = sdl.IMG_Load("foo.png");
const texture = sdl.SDL_CreateTextureFromSurface(renderer, surface);
```

[1]: https://github.com/libsdl-org/SDL_image
[2]: https://ziglang.org
[3]: https://github.com/allyourcodebase/SDL
