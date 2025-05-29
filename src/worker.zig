// ============================================================================
// Optimized Worker Thread Module - Reduced Contention Version
//
// This version uses local statistics to minimize mutex contention:
// - Each worker maintains local stats
// - Synchronization happens in batches (every 10k games)
// - Dramatically reduces mutex lock/unlock frequency
// ============================================================================

const std = @import("std");
const Grid = @import("grid.zig").Grid;
const SharedState = @import("shared_state.zig").SharedState;
const LocalStats = @import("shared_state.zig").LocalStats;

// Optimized worker thread function with batched updates
pub fn workerThread(shared_state: *SharedState, allocator: std.mem.Allocator) void {
    var grid = Grid.init();
    var local_stats = LocalStats.init(allocator);
    defer local_stats.deinit();

    while (true) {
        grid = Grid.init(); // Reset grid for new game

        // Play a random game
        const score = grid.playRandomGame();

        // Update LOCAL stats (no synchronization needed)
        local_stats.updateLocalScore(score, &grid);

        // Periodically flush to global state (much less frequent)
        if (local_stats.shouldFlush()) {
            shared_state.flushLocalStats(&local_stats);
        }
    }
}

// Legacy worker function for backwards compatibility (deprecated)
pub fn legacyWorkerThread(shared_state: *SharedState) void {
    var grid = Grid.init();

    while (true) {
        grid = Grid.init(); // Reset grid for new game

        // Play a random game and handle any errors gracefully
        const score = grid.playRandomGame();

        // Update shared state with the game result (causes mutex contention)
        shared_state.updateScore(score, &grid);
    }
}

// Enhanced performance monitoring with less frequent reporting
pub fn performanceMonitor(shared_state: *SharedState) void {
    var last_games_count: u64 = 0;
    var last_report_time = std.time.milliTimestamp();
    const report_interval_ms: i64 = 2000; // Report every 2 seconds (more frequent for better UX)

    // Get CPU count for efficiency calculation
    // const cpu_count = std.Thread.getCpuCount() catch 4;
    // const unoptimized_baseline = 1900000.0; // 1.9M games/sec from unoptimized version
    // const expected_per_core = unoptimized_baseline / @as(f64, @floatFromInt(cpu_count));

    while (true) {
        std.time.sleep(500_000_000); // Sleep for 0.5 seconds (check more frequently)

        const current_time = std.time.milliTimestamp();

        if (current_time - last_report_time >= report_interval_ms) {
            const stats = shared_state.getStats();
            const games_in_interval = stats.games_played - last_games_count;
            const time_elapsed_sec = @as(f64, @floatFromInt(current_time - last_report_time)) / 1000.0;
            const games_per_second = @as(f64, @floatFromInt(games_in_interval)) / time_elapsed_sec;

            // Calculate efficiency against unoptimized baseline
            // const efficiency = (games_per_second / unoptimized_baseline) * 100.0;

            std.debug.print("Performance: {d:.1} games/sec | Best: {} | Solutions: {}\n", .{ games_per_second, stats.best_score, stats.solutions_found });

            last_report_time = current_time;
            last_games_count = stats.games_played;
        }
    }
}
