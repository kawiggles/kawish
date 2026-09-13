const std = @import("std");
const Io = std.Io;

const Cmd = @import("command.zig").Command;

pub fn run(writer: *Io.Writer, reader: *Io.Reader, path: []const u8, alloc: std.mem.Allocator) !void {
    var cmd_cache: std.StringHashMap([]const u8) = .init(alloc);

    try printPrompt(writer);
    while (try reader.takeDelimiter('\n')) |line| {
        const cmd: Cmd = Cmd.init(line, &cmd_cache, path, alloc) catch |err| switch (err) {
            error.EmptyCommand => {
                try printPrompt(writer);
                continue;
            },
            error.FileNotInPATH => {
                std.debug.print("Command not found\n", .{});
                try printPrompt(writer);
                continue;
            },
            else => return err,
        };

        try cmd.exec();

        try printPrompt(writer);
    }
}

fn printPrompt(writer: *Io.Writer) !void {
    try writer.print("kawish> ", .{});
    try writer.flush();
}
