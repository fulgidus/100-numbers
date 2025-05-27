// ============================================================================
// 100 Numbers Game Solver in Zig - Main Entry Point
//
// This program solves the "100 Numbers Game" on a 10x10 grid. The objective
// is to fill the grid with numbers from 1 to 100, starting from any cell,
// following specific movement rules:
// - Each move must jump two cells horizontally or vertically, or one cell
//   diagonally.
// - Moves cannot revisit any previously filled cell.
// - The goal is to fill all 100 cells without violating the movement rules.
//
// The solver uses multithreading to maximize CPU utilization and finds
// solutions faster. Each solution found is saved to a text file named using
// the hash of the solution grid, ensuring uniqueness and easy identification.
//
// Architecture:
// - grid.zig: Core game logic and grid operations
// - shared_state.zig: Thread-safe state management
// - worker.zig: Worker thread functions and performance monitoring
// - main.zig: Application entry point and thread coordination
// ============================================================================

const std = @import("std");
const Grid = @import("grid.zig").Grid;
const SharedState = @import("shared_state.zig").SharedState;
const worker = @import("worker.zig");

pub fn main() !void {
    std.debug.print("*** Starting 100 Numbers Game Solver (Multithreaded) ***\n", .{});
    std.debug.print("Press Ctrl+C to stop\n\n", .{});

    // Get number of CPU cores for optimal thread allocation
    const cpu_count = std.Thread.getCpuCount() catch 4; // Default to 4 if detection fails
    std.debug.print("Using {} threads (CPU cores detected)\n", .{cpu_count});

    // Initialize shared state for thread coordination
    var shared_state = SharedState.init();

    // Create thread pool for worker threads
    var threads = std.ArrayList(std.Thread).init(std.heap.page_allocator);
    defer threads.deinit();

    // Start worker threads - each runs continuous game simulations
    for (0..cpu_count) |i| {
        const thread = try std.Thread.spawn(.{}, worker.workerThread, .{&shared_state});
        try threads.append(thread);
        std.debug.print("Started worker thread #{}\n", .{i + 1});
    }

    // Start performance monitoring thread for statistics reporting
    const perf_thread = try std.Thread.spawn(.{}, worker.performanceMonitor, .{&shared_state});
    std.debug.print("Started performance monitor thread\n\n", .{});

    // Wait for threads to complete (they run forever until Ctrl+C)
    for (threads.items) |thread| {
        thread.join();
    }
    perf_thread.join();
}
