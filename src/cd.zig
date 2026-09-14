const std = @import("std");
const posix = std.posix;
const mem = std.mem;

pub const Cd = struct {
    const Self = @This();
    target: []const u8,

    pub fn init(input: []const u8, cache: *std.StringHashMap, ) !Self {
    }

    pub fn exec(self: *const Cd) !void {
    }
};
