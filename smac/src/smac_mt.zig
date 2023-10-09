const std = @import("std");
const rnd_gen = std.rand.DefaultPrng;
const heap_alloc = std.heap.page_allocator;

pub fn main() !void {
    const x = 4;
    var t: [x]std.Thread = undefined;
    var list: [x]std.ArrayList(u8) = undefined;

    var i: u32 = 0;
    while (i < x) : (i += 1) {
        list[i] = std.ArrayList(u8).init(heap_alloc);
        defer list[i].deinit();
        t[i] = try std.Thread.spawn(.{}, count_it, .{ @as(u32, @truncate(i)), &list[i] });
    }

    i = 0;
    while (i < x) : (i += 1) {
        t[i].join();
        try print_list(&list[i]);
        list[i].clearAndFree();
    }
}

fn print_list(list: *std.ArrayList(u8)) !void {
    var iter = std.mem.split(u8, list.items, "\n");
    const stdout = std.io.getStdOut().writer();
    while (iter.next()) |item| {
        try stdout.print("{s}\n", .{item});
    }
}

fn count_it(id: u32, list: *std.ArrayList(u8)) !void {
    var addr: usize = 0;
    if (id == 3) addr += 1;

    var index: usize = id * 250000;
    while (index < (id * 250000 + 250000 + addr)) : (index += 1) {
        if (index == 0) continue;

        if (index % 7 == 0 or index % 10 == 7) {
            try list.writer().print("{s}\n", .{"SMAC"});
        } else {
            try list.writer().print("{d}\n", .{index});
        }
    }
}
