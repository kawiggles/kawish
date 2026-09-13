const std = @import("std");
const posix = std.posix;
const mem = std.mem;

pub const Command = struct {
    const Self = @This();
    pub const Error = error{EmptyCommand};
    bin: []const u8,
    input: []const u8,

    pub fn init(input: []const u8) Error!Self {
        var tokens = mem.splitScalar(u8, input, ' ');
        const bin = tokens.next() orelse return error.EmptyCommand;
        if (bin.len == 0) return error.EmptyCommand;

        return .{
            .bin = bin,
            .input = input,
        };
    }

    pub fn exec(self: *const Command) !void {
        // clone the process, where the child is pid 0
        // basically converting from zig errno to c errno for system syscalls
        const raw = posix.system.fork(); 
        if (posix.errno(raw) != .SUCCESS) return error.ForkFailed;
        const pid: i32 = @intCast(raw); 

        if (pid == 0) { // only the child will be executing the command
            var arg_bufs: [64][256]u8 = undefined;
            var argv: [65]?[*:0]const u8 = undefined;

            var tokens = mem.splitScalar(u8, self.input, ' ');
            var i: usize = 0;
            while (tokens.next()) |token| : (i += 1) {
                argv[i] = mem.printSentinel(&arg_bufs[i], "{s}", .{token}, 0) catch
                    posix.system.exit(127);
            }
            argv[i] = null;

            var bin_buf: [256]u8 = undefined;
            const bin: [*:0]const u8 = mem.printSentinel(&bin_buf, "/bin/{s}", .{self.bin}, 0) catch
                posix.system.exit(127);

            _ = posix.system.execve(bin, @ptrCast(&argv), std.c.environ);
            posix.system.exit(127); // shouldn't reach here cause of execve
        }

        var status: i32 = undefined;

        const wait_result = posix.system.waitpid(pid, &status, 0);
        if (wait_result == -1) return error.WaitFailed;

        // if (posix.W.IFEXITED(@bitCast(status))) {
        //     std.debug.print("child process exited with code: {d}\n", .{
        //         posix.W.EXITSTATUS(@bitCast(status)),
        //     });
        // }
    }
};
