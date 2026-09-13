const std = @import("std");
const builtin = @import("builtin");

const kawish = @import("kawish");

pub fn main(init: std.process.Init) !u8 {
    const arena = init.arena;
    defer arena.deinit();
    const allocator = arena.allocator();

    const io = init.io;
    const path = init.environ_map.get("PATH") orelse
        std.debug.panic("Your PATH is missing", .{});

    var stdin_buf: [1024]u8 = undefined;
    var stdin_file_reader: std.Io.File.Reader = .init(.stdin(), io, &stdin_buf);
    const stdin = &stdin_file_reader.interface;

    var stdout_buf: [1024]u8 = undefined;
    var stdout_file_writer: std.Io.File.Writer = .init(.stdout(), io, &stdout_buf);
    const stdout = &stdout_file_writer.interface;

    try kawish.run(stdout, stdin, path, allocator);

    return 0;
}
