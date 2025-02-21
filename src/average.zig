const std = @import("std");
const fmt = std.fmt;
const io = std.io;
const heap = std.heap;

fn calculateAverage(grades: []const f64) !f64 {
    if (grades.len == 0) return error.EmptySlice;
    var sum: f64 = 0.0;
    for (grades) |grade| {
        sum += grade;
    }
    return sum / @as(f64, @floatFromInt(grades.len));
}

pub fn main() !void { // <-- Opening brace for main
    const stdout = io.getStdOut().writer();
    const stdin = io.getStdIn().reader();
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var buffer: [1024]u8 = undefined;

    try stdout.print("Digite o número de alunos: ", .{});
    const n_input = try stdin.readUntilDelimiterOrEof(&buffer, '\n') orelse return error.InvalidInput;
    const n = try fmt.parseInt(usize, std.mem.trim(u8, n_input, &std.ascii.whitespace), 10);

    if (n == 0) {
        try stdout.print("Número de alunos deve ser maior que 0.\n", .{});
        return;
    }

    var notas = try allocator.alloc(f64, n);
    defer allocator.free(notas);

    for (0..n) |i| {
        try stdout.print("Digite a {d}ª. nota: ", .{i + 1});
        const grade_input = try stdin.readUntilDelimiterOrEof(&buffer, '\n') orelse return error.InvalidInput;
        const grade = try fmt.parseFloat(f64, std.mem.trim(u8, grade_input, &std.ascii.whitespace));
        notas[i] = grade;
    }

    const media = try calculateAverage(notas);
    try stdout.print("A média dos alunos é: {d:.2}\n", .{media});
} // <-- Closing brace for main was missing

test "calculate average with valid input" {
    const grades = [_]f64{ 7.5, 8.0, 6.5, 9.0 };
    const avg = try calculateAverage(&grades);
    try std.testing.expectApproxEqAbs(@as(f64, 7.75), avg, 0.001);
}

test "empty array returns error" {
    try std.testing.expectError(error.EmptySlice, calculateAverage(&.{ }));
}

test "handle negative numbers" {
    const grades = [_]f64{ -2.0, 0.0, 2.0 };
    const avg = try calculateAverage(&grades);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), avg, 0.001);
}

test "single element array" {
    const grades = [_]f64{ 4.5 };
    const avg = try calculateAverage(&grades);
    try std.testing.expectApproxEqAbs(@as(f64, 4.5), avg, 0.001);
}