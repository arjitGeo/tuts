const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var biglist = std.ArrayList(u8).init(std.heap.page_allocator);
    defer biglist.deinit();

    for (1..1000001) |index| {
        if (index % 10 == 7 or index % 7 == 0) {
            try biglist.writer().print("{s}\n", .{"SMAC"});
        } else {
            try biglist.writer().print("{d}\n", .{index});
        }
    }

    try print_list(&biglist);
    biglist.clearAndFree();
}

fn print_list(list: *std.ArrayList(u8)) !void {
    for (list.items) |item| {
        try stdout.print("{c}", .{item});
    }
}
