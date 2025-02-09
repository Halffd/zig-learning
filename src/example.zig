const std = @import("std");

pub fn main() void {
 const pred = true;
 if (pred) {
 var foo: []const u8 = "hello world";
 std.debug.print("{s}\n", .{foo});
 foo = "bye bye world";
 std.debug.print("{s}\n", .{foo});
 } else std.debug.print("false", .{});
}