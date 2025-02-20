const std = @import("std");

pub fn main() !void {
    var notas: [10]f64 = undefined;
    var soma: f64 = 0.0;
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buffer: [1024]u8 = undefined;

    for (0..10) |i| {
        try stdout.print("Digite a {d}ª. nota: ", .{i + 1});
        const input = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) orelse return error.InvalidInput;
        const trimmed_input = std.mem.trim(u8, input, &std.ascii.whitespace);
        const nota = try std.fmt.parseFloat(f64, trimmed_input);
        notas[i] = nota;
        soma += nota;
    }

    const media = soma / 10.0;
    try stdout.print("A média dos alunos é : {d:.2}\n", .{media});
}