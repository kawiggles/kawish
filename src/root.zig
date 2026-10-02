const std = @import("std");
const Io = std.Io;
const mem = std.mem;
const fs = std.fs;

const Binary = @import("binary.zig").Binary;
const parser = @import("parser.zig");
const ParsedLine = parser.ParsedLine;
const TokenType = parser.TokenType;

pub const Shell = struct {
    const Self = @This();
    io: Io,
    reader: *Io.Reader,
    writer: *Io.Writer,
    path: []const u8,
    cmd_cache: std.StringHashMap([]const u8),
    allocator: mem.Allocator,

    pub fn init(
        writer: *Io.Writer,
        reader: *Io.Reader,
        path: []const u8,
        alloc: mem.Allocator,
        io: Io,
    ) !Self {
        const cmd_cache: std.StringHashMap([]const u8) = .init(alloc);

        return .{ 
            .io = io,
            .reader = reader,
            .writer = writer,
            .path = path,
            .cmd_cache = cmd_cache,
            .allocator = alloc,
        };
    }

    pub fn run(self: *Shell) !void {
        try self.printPrompt();

        while (try self.reader.takeDelimiter('\n')) |line| {
            const parsed = try ParsedLine.init(line, self.allocator);

            self.exec(&parsed) catch |err| switch (err) {
                error.EmptyCommand => {
                    try self.printPrompt();
                },
                error.FileNotInPATH => {
                    std.debug.print("Binary not found\n", .{});
                    try self.printPrompt();
                },
                else => {
                    std.debug.print("Error encountered: {}\n", .{err});
                    return err;
                },
            };

            try self.printPrompt();
        }
    }

    fn printPrompt(self: *Shell) !void {
        var dir = try Io.Dir.cwd().openDir(self.io, ".", .{});
        defer dir.close(self.io);

        var buf: [fs.max_path_bytes]u8 = undefined;
        const len = try dir.realPathFile(self.io, ".", &buf);
        const name = fs.path.basename(buf[0..len]);

        try self.writer.print("{s}> ", .{ name });
        try self.writer.flush();
    }

    fn exec(self: *Shell, line: *const ParsedLine) !void {
        const first = line.tokens.items[0];
        switch (first.t) {
            .word => { 
                if (std.mem.eql(u8, first.text, "cd")) {
                    const target = line.tokens.items[1];
                    if (target.t != TokenType.word or target.text.len == 0) return error.BadTarget;
                    var dir = try std.Io.Dir.cwd().openDir(self.io, target.text, .{});
                    defer dir.close(self.io);

                    try std.process.setCurrentDir(self.io, dir);
                } else {
                    const bin = try Binary.init(line.line, &self.cmd_cache, self.path, self.allocator);
                    try bin.exec();
                }
            },
            .literal, .pipe, .redir_out, .redir_in, .bgrd, .semicolon => undefined,
            .eof => return,
        }

        return;
    }
};
