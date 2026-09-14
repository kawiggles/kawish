const cmd = @import("command.zig");
const cd = @import("cd.zig");

const Node = union(enum) {
    command: cmd.Command,
    cd: cd.Cd,

    fn exec(self: *Node) !void {
        switch (self.*) {
            .command => |*c| try c.exec(),
        }
    }
};
