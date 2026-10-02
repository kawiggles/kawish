const std = @import("std");
const Binary = @import("binary.zig").Binary;
const mem = std.mem;

pub const ParsedLine = struct {
    const Self = @This();
    line: []const u8,
    tokens: std.ArrayList(Token),
    allocator: mem.Allocator,

    /// Takes in a string and outputs an array of tokens with an allocator and the input string
    pub fn init(raw: []const u8, alloc: mem.Allocator) !Self {
        const input = try alloc.dupe(u8, raw);

        var tokens: std.ArrayList(Token) = .empty;
        var pos: usize = 0;
        // TODO: add condition to this loop
        while (true) {
            const tok = nextToken(raw, &pos);
            std.debug.print("Token lexed: {s}\n", .{tok.text});
            try tokens.append(alloc, tok);
            if (tok.t == TokenType.eof) { break; }
        }

        return .{ .line = input, .tokens = tokens, .allocator = alloc };
    }

    /// Frees token array and input string
    pub fn deinit(self: *const ParsedLine) void {
        self.allocator.free(self.tokens);
        self.allocator.free(self.input);
    }

    pub fn exec(
        self: *const ParsedLine,
        cmd_cache: *std.StringHashMap([]const u8),
        path: []const u8,
        alloc: mem.Allocator
    ) !void {
        const first = self.tokens.items[0];
        switch (first.t) {
            .word => { 
                if (mem.eql(u8, first.text, "cd")) {
                    std.debug.print("do a cd to path {s}\n", .{self.tokens.items[1].text});
                } else {
                    const cmd = try Binary.init(self.line, cmd_cache, path, alloc);
                    try cmd.exec();
                }
            },
            .literal, .pipe, .redir_out, .redir_in, .bgrd, .semicolon => undefined,
            .eof => return,
        }
    }

};

const TokenType = enum { word, literal, pipe, redir_out, redir_in, bgrd, semicolon, eof };

const Token = struct {
    t: TokenType,
    text: []const u8,
};

fn nextToken(input: []const u8, pos: *usize) Token {
    while (pos.* < input.len and input[pos.*] == ' ') pos.* += 1;
    if (pos.* >= input.len) return .{ .t = .eof, .text = "" };

    switch (input[pos.*]) {
        '|' => { pos.* += 1; return .{ .t = .pipe, .text = "|" }; },
        '>' => { pos.* += 1; return .{ .t = .redir_out, .text = ">" }; },
        '<' => { pos.* += 1; return .{ .t = .redir_in, .text = "<" }; },
        '&' => { pos.* += 1; return .{ .t = .bgrd, .text = "&" }; },
        ';' => { pos.* += 1; return .{ .t = .semicolon, .text = ";" }; },
        '"' => {
            pos.* += 1;
            const start = pos.*;
            while (pos.* < input.len and input[pos.*] != '"') pos.* += 1;
            const text = input[start..pos.*];
            if (pos.* < input.len) pos.* += 1;
            return .{ .t = .literal, .text = text };
        },
        else => {
            const start = pos.*;
            while (pos.* < input.len and input[pos.*] != ' ') pos.* += 1;
            return .{ .t = .word, .text = input[start..pos.*] };
        },
    }
}
