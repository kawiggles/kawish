const std = @import("std");
const mem = std.mem;

pub const ParsedLine = struct {
    const Self = @This();
    input: []const u8,
    tokens: std.ArrayList(Token),
    allocator: mem.Allocator,

    pub fn init(raw: []const u8, alloc: mem.Allocator) !Self {
        const input = try alloc.dupe(u8, raw);

        var tokens: std.ArrayList(Token) = .empty;
        var pos: usize = 0;
        while (true) {
            const tok = nextToken(raw, &pos);
            std.debug.print("Token lexed: {s}\n", .{tok.text});
            try tokens.append(alloc, tok);
        }

        return .{ .input = input, .tokens = tokens, .allocator = alloc };
    }

    pub fn deinit(self: *const ParsedLine) void {
        self.allocator.free(self.tokens);
        self.allocator.free(self.input);
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
