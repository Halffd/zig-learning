const std = @import("std");
const expect = std.testing.expect;
const Allocator = std.mem.Allocator;

// Define a simple struct to test allocations
const TestData = struct {
    value: i32,
    name: []u8,
};

// Function to create and populate TestData using an allocator
fn createTestData(allocator: Allocator, value: i32, name: []const u8) !TestData {
    const name_copy = try allocator.dupe(u8, name);
    return TestData{ .value = value, .name = name_copy };
}

// Function to clean up TestData
fn destroyTestData(allocator: Allocator, data: TestData) void {
    allocator.free(data.name);
}

pub fn main() !void {
    // For demonstration, we'll use a GeneralPurposeAllocator in main
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    std.debug.print("Running allocator tests...\n", .{});

    // Run tests for each allocator
    try testPageAllocator(allocator);
    try testFixedBufferAllocator(allocator);
    try testArenaAllocator(allocator);
    try testGeneralPurposeAllocator(allocator);
    try testCAllocator(allocator);
}

fn testPageAllocator(_: Allocator) !void {
    std.debug.print("\nTesting std.heap.page_allocator (best for: large, infrequent allocations from OS)...\n", .{});

    const allocator = std.heap.page_allocator;

    const large_buffer = try allocator.alloc(u8, 1024 * 1024); // 1MB
    defer allocator.free(large_buffer);

    try expect(large_buffer.len == 1024 * 1024);
    std.debug.print("Allocated 1MB buffer successfully with page_allocator.\n", .{});
}

fn testFixedBufferAllocator(_: Allocator) !void {
    std.debug.print("\nTesting std.heap.FixedBufferAllocator (best for: fixed-size, no heap allocations, stack-based)...\n", .{});

    var buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const small_slice = try allocator.alloc(u8, 100);
    defer allocator.free(small_slice);

    try expect(small_slice.len == 100);
    std.debug.print("Allocated 100 bytes successfully with FixedBufferAllocator (no heap allocation).\n", .{});

    const too_big = allocator.alloc(u8, 2000);
    try expect(too_big == error.OutOfMemory);
}

fn testArenaAllocator(parent_allocator: Allocator) !void {
    std.debug.print("\nTesting std.heap.ArenaAllocator (best for: multiple allocations, freed all at once, e.g., request/response handling)...\n", .{});

    var arena = std.heap.ArenaAllocator.init(parent_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const data1 = try createTestData(allocator, 42, "Test1");
    const data2 = try createTestData(allocator, 84, "Test2");
    defer destroyTestData(allocator, data1);
    defer destroyTestData(allocator, data2);

    try expect(data1.value == 42);
    try expect(std.mem.eql(u8, data1.name, "Test1"));
    try expect(data2.value == 84);
    try expect(std.mem.eql(u8, data2.name, "Test2"));

    std.debug.print("Allocated and managed multiple objects with ArenaAllocator (all freed at once).\n", .{});
}

fn testGeneralPurposeAllocator(_: Allocator) !void {
    std.debug.print("\nTesting std.heap.GeneralPurposeAllocator (best for: general use, safe, detects leaks, most programs)...\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const data = try createTestData(allocator, 100, "GPA Test");
    defer destroyTestData(allocator, data);

    try expect(data.value == 100);
    try expect(std.mem.eql(u8, data.name, "GPA Test"));

    std.debug.print("Allocated and managed data with GeneralPurposeAllocator (safe, general use).\n", .{});
}

fn testCAllocator(_: Allocator) !void {
    std.debug.print("\nTesting std.heap.c_allocator (best for: interoperability with C, performance-critical, unsafe)...\n", .{});

    const allocator = std.heap.c_allocator;

    const buffer = try allocator.alloc(u8, 500);
    defer allocator.free(buffer);

    try expect(buffer.len == 500);
    std.debug.print("Allocated 500 bytes with c_allocator (fast, unsafe, for C interop).\n", .{});
}

test "all allocators" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    try testPageAllocator(gpa.allocator());
    try testFixedBufferAllocator(gpa.allocator());
    try testArenaAllocator(gpa.allocator());
    try testGeneralPurposeAllocator(gpa.allocator());
    try testCAllocator(gpa.allocator());
}