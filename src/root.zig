const std = @import("std");
const Io = std.Io;
const mem = std.mem;

const Binary = @import("binary.zig").Binary;
const ParsedLine = @import("parser.zig").ParsedLine;

pub const Shell = struct {
    const Self = @This();
    reader: *Io.Reader,
    writer: *Io.Writer,
    path: []const u8,
    wd: Io.Dir,
    cmd_cache: std.StringHashMap([]const u8),
    allocator: mem.Allocator,

    pub fn init(writer: *Io.Writer, reader: *Io.Reader, path: []const u8, alloc: mem.Allocator) !Self {
        const cmd_cache: std.StringHashMap([]const u8) = .init(alloc);

        return .{ 
            .reader = reader,
            .writer = writer,
            .path = path,
            .wd = Io.Dir.cwd(),
            .cmd_cache = cmd_cache,
            .allocator = alloc,
        };
    }

    pub fn run(self: *Shell) !void {
        try printPrompt(self.writer);

        while (try self.reader.takeDelimiter('\n')) |line| {
            const parsed = try ParsedLine.init(line, self.allocator);

            parsed.exec(&self.cmd_cache, self.path, self.allocator) catch |err| switch (err) {
                error.EmptyCommand => {
                    try printPrompt(self.writer);
                },
                error.FileNotInPATH => {
                    std.debug.print("Binary not found\n", .{});
                    try printPrompt(self.writer);
                },
                else => return err,
            };
        }

        try printPrompt(self.writer);
    }
};


fn printPrompt(writer: *Io.Writer) !void {
    try writer.print("kawish> ", .{});
    try writer.flush();
}
