const std = @import("std");

// Helper function to print hexadecimal dump
fn dump_hex(buffer: []const u8) void {
    for (buffer, 0..) |byte, i| {
        if (i % 16 == 0) {
            std.debug.print("\n{x:0>8}: ", .{i});
        }
        std.debug.print("{x:0>2} ", .{byte});
        if (i % 16 == 7) std.debug.print(" ", .{});
    }
    std.debug.print("\n", .{});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Get command line arguments
    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    if (argv.len < 2) {
        std.debug.print("Usage: {s} <filename>\n", .{argv[0]});
        return error.InvalidArguments;
    }

    const file_path = argv[1];
    
    // Open the file with proper error handling
    const file = std.fs.cwd().openFile(file_path, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("Error: File '{s}' not found\n", .{file_path});
            return;
        },
        error.AccessDenied => {
            std.debug.print("Error: Access denied to '{s}'\n", .{file_path});
            return;
        },
        else => {
            std.debug.print("Error opening file: {}\n", .{err});
            return;
        },
    };
    defer file.close();

    // Get file statistics
    const f_stats = try file.stat();
    
    // Handle empty files
    if (f_stats.size == 0) {
        std.debug.print("File '{s}' is empty\n", .{file_path});
        return;
    }

    // Allocate buffer matching file size
    const f_buf = try allocator.alloc(u8, f_stats.size);
    
    // Read entire file into buffer
    const bytes_read = try file.readAll(f_buf);
    
    // Verify complete read
    if (bytes_read != f_stats.size) {
        std.debug.print("Warning: Only read {d} of {d} bytes\n", .{bytes_read, f_stats.size});
    }

    // Print header
    std.debug.print("Hex dump of '{s}' ({d} bytes):\n", .{file_path, f_stats.size});
    
    // Print hex dump
    dump_hex(f_buf);
}