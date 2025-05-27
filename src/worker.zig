// ============================================================================
// Worker Thread Module for 100 Numbers Game Solver
//
// This module contains the worker thread functions that handle:
// - Individual game simulation threads
// - Performance monitoring and statistics reporting
// - Continuous game execution with proper error handling
// ============================================================================

const std = @import("std");
const Grid = @import("grid.zig").Grid;
const SharedState = @import("shared_state.zig").SharedState;

// Main worker thread function - runs continuous game simulations
pub fn workerThread(shared_state: *SharedState) void {
    var grid = Grid.init();

    while (true) {
        grid = Grid.init(); // Reset grid for new game

        // Play a random game and handle any errors gracefully
        const score = grid.playRandomGame();

        // Update shared state with the game result
        shared_state.updateScore(score, &grid);
    }
}

// Performance monitoring thread - reports statistics periodically
pub fn performanceMonitor(shared_state: *SharedState) void {
    var last_games_count: u64 = 0;
    var last_report_time = std.time.milliTimestamp();
    const report_interval_ms: i64 = 5000; // Report every 5 seconds

    while (true) {
        std.time.sleep(1_000_000_000); // Sleep for 1 second (nanoseconds)

        const current_time = std.time.milliTimestamp();

        // Check if it's time to report performance statistics
        if (current_time - last_report_time >= report_interval_ms) {
            const stats = shared_state.getStats();
            const games_in_interval = stats.games_played - last_games_count;
            const time_elapsed_sec = @as(f64, @floatFromInt(current_time - last_report_time)) / 1000.0;
            const games_per_second = @as(f64, @floatFromInt(games_in_interval)) / time_elapsed_sec;

            // Print performance statistics
            std.debug.print("Performance: {d:.1} games/second | Best: {} | Perfect solutions: {}\n", .{ games_per_second, stats.best_score, stats.solutions_found });

            // Update tracking variables for next interval
            last_report_time = current_time;
            last_games_count = stats.games_played;
        }
    }
}
