const std = @import("std");
const Io = std.Io;

const Cmd = @import("command.zig").Command;

pub fn run(writer: *Io.Writer, reader: *Io.Reader) !void {
    try printPrompt(writer);

    while (try reader.takeDelimiter('\n')) |line| {
        const cmd: Cmd = Cmd.init(line) catch |err| if (err == error.EmptyCommand) {
            try printPrompt(writer);
            continue;
        } else { return err; };

        try cmd.exec();

        try printPrompt(writer);
    }
}

fn printPrompt(writer: *Io.Writer) !void {
    try writer.print("kawish> ", .{});
    try writer.flush();
}
