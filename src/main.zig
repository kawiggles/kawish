const std = @import("std");
const builtin = @import("builtin");

const kawish = @import("kawish");

pub fn main(init: std.process.Init) !u8 {
    const io = init.io;

    var stdin_buf: [1024]u8 = undefined;
    var stdin_file_reader: std.Io.File.Reader = .init(.stdin(), io, &stdin_buf);
    const stdin = &stdin_file_reader.interface;


    var stdout_buf: [1024]u8 = undefined;
    var stdout_file_writer: std.Io.File.Writer = .init(.stdout(), io, &stdout_buf);
    const stdout = &stdout_file_writer.interface;

    try kawish.run(stdout, stdin);

    return 0;
}
