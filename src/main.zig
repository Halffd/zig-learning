const std = @import("std");

pub fn main() void {
    var dummy_int: i32 = 0;
    var dummy_float: f32 = 0.0;

    // Changed from var to const since we're not modifying the pointers
    const p: *i32 = &dummy_int;
    const ptr1: *f32 = &dummy_float;
    const ptr2: *f32 = &dummy_float;

    std.debug.print("Pointer values:\n", .{});
    std.debug.print("p: {*}\nptr1: {*}\nptr2: {*}\n", .{p, ptr1, ptr2});
}