const std = @import("std");
const ArrayList = std.ArrayList;

// Define a custom error set for better error handling
const MyErrors = error{
    CalculationFailure,
    MemoryAllocationFailure,
    InvalidOperation,
};

// Define a structure to hold some state (for demonstration)
const State = struct {
    counter: u32,
    is_valid: bool,

    // Constructor for the State struct
    pub fn init(count: u32) State {
        return State{
            .counter = count,
            .is_valid = true,
        };
    }

    // Method to update the state safely
    pub fn update(self: *State, increment: u32) !void {
        if (increment > 1000) return MyErrors.InvalidOperation; // Safety check
        self.counter += increment;
        if (self.counter > 1_000_000) self.is_valid = false; // Prevent overflow
    }
};

/// A function that intentionally fails based on a mathematical impossibility,
/// demonstrating error handling in Zig.
/// This function checks if 2 + 2 equals 5, which will always return an error.
fn gonnaFail() MyErrors!void {
    // Use a safety check to ensure we're working with valid integers
    if (@typeInfo(@TypeOf(2 + 2)) != .Int) {
        std.debug.print("Error: Unexpected type in calculation\n", .{});
        return MyErrors.CalculationFailure;
    }

    // Perform the check and return an error if the condition is met
    if (2 + 2 == 5) {
        std.debug.print("Mathematical impossibility detected: 2 + 2 == 5!\n", .{});
        return MyErrors.CalculationFailure;
    }

    // If we reach here, the operation is theoretically impossible to fail,
    // but we return success for completeness
    return;
}

/// Main entry point of the program, demonstrating compile-time computation,
/// runtime execution, memory safety, and ArrayList usage.
pub fn main() !void {
    // Initialize an Arena allocator for safe memory management
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit(); // Ensure all memory is cleaned up when we exit
    const allocator = arena.allocator();

    // Allocate memory safely for a buffer, with error checking
    const buffer_size: usize = 1024; // More verbose buffer size definition
    const memory_buffer = allocator.alloc(u8, buffer_size) catch |err| {
        std.debug.print("Failed to allocate memory: {any}\n", .{err});
        return MyErrors.MemoryAllocationFailure;
    };
    defer allocator.free(memory_buffer); // Clean up the buffer when done

    // Initialize all bytes in the buffer to zero for safety
    for (memory_buffer) |*byte| {
        byte.* = 0;
    }

    // Perform a compile-time loop for demonstration
    // Removed std.debug.print since it's not allowed at compile time
    comptime {
        var i: u32 = 0;
        while (i < 420) : (i += 1) {
            if (i % 42 == 0) {
                // No printing here—use this for compile-time logic only
            }
        }
    }

    // Create and manage a state object with safety checks
    var state = State.init(0);
    var attempt_count: u32 = 0;
    while (attempt_count < 5) : (attempt_count += 1) {
        state.update(10) catch |err| {
            std.debug.print("State update failed on attempt {d}: {any}\n", .{attempt_count, err});
            if (err == MyErrors.InvalidOperation) break; // Safely exit on invalid operation
        };
    }

    // Create an ArrayList of i32 using the same allocator
    var list = ArrayList(i32).init(allocator);
    defer list.deinit(); // Ensure list memory is freed

    // Example: Add elements to the list
    list.append(10) catch |err| {
        std.debug.print("Failed to append to list: {any}\n", .{err});
        return MyErrors.MemoryAllocationFailure;
    };
    list.append(20) catch |err| {
        std.debug.print("Failed to append to list: {any}\n", .{err});
        return MyErrors.MemoryAllocationFailure;
    };
    list.append(30) catch |err| {
        std.debug.print("Failed to append to list: {any}\n", .{err});
        return MyErrors.MemoryAllocationFailure;
    };

    // Print the list contents
    std.debug.print("List contents: {any}\n", .{list.items});

    // Attempt to call the function that will fail, with proper error handling
    gonnaFail() catch |err| {
        std.debug.print("Function gonnaFail failed with error: {any}\n", .{err});
        // Handle the error gracefully instead of crashing
        if (err == MyErrors.CalculationFailure) {
            std.debug.print("Recovered from mathematical impossibility safely.\n", .{});
        }
    };

    // Print the final state for verification
    std.debug.print(
        "Program completed successfully. Final state: counter={d}, is_valid={any}\n",
        .{ state.counter, state.is_valid },
    );

    // Additional safety check to ensure no memory leaks or invalid states
    if (!state.is_valid) {
        std.debug.print("Warning: State became invalid during execution!\n", .{});
        return MyErrors.InvalidOperation;
    }
}