const std = @import("std");
const posix = std.posix;

pub const Command = struct {
    const Self = @This();
    bin: []const u8,

    pub fn init(input: []const u8) !Self {
        var tokens = std.mem.splitScalar(u8, input, ' ');
        
        const bin = tokens.next() orelse return error.EmptyCommand;
        if (bin.len == 0) return error.EmptyCommand;

        return .{
            .bin = bin,
        };
    }

    pub fn exec(self: *const Command) !void {
        // clone the process, where the child is pid 0
        // basically converting from zig errno to c errno for system syscalls
        const raw = posix.system.fork(); 
        if (posix.errno(raw) != .SUCCESS) return error.ForkFailed;
        const pid: i32 = @intCast(raw); 

        if (pid == 0) { // only the child will be executing the command
            std.debug.print("I'm the child, and I would execute {s}\n", .{self.bin});
            posix.system.exit(0); // kill so that both processes aren't doing the following
        }

        var status: i32 = undefined;

        const child_pid = posix.system.waitpid(pid, &status, 0);

        if (posix.W.IFEXITED(@bitCast(status))) {
            std.debug.print("child process {} exited with code: {d}\n", .{
                child_pid,
                posix.W.EXITSTATUS(@bitCast(status)),
            });
        }
    }
};
