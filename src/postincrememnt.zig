const std = @import("std");

// Required main function for executables
pub fn main() !void {
    std.debug.print("Running tests...\n", .{});
    // Optionally run tests from main
    std.testing.refAllDecls(@This());
}

// Test with proper syntax
test "postincrement" {
    var i: u32 = 0;
    const s = blk: {
        defer i += 1;
        break :blk i;
    };
    
    try std.testing.expectEqual(@as(u32, 0), s);
    try std.testing.expectEqual(@as(u32, 1), i);
}