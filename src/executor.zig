const bin = @import("binary.zig");
const cd = @import("cd.zig");

const Node = union(enum) {
    binary: bin.Binary,
    cd: cd.Cd,

    fn exec(self: *Node) !void {
        switch (self.*) {
            .binary => |*b| try b.exec(),
            .cd => |*c| try c.exec(),
            .pipe => |*p| try p.exec(),
        }
    }
};
