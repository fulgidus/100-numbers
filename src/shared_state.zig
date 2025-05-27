// ============================================================================
// Optimized Shared State Module - Performance Improvements
//
// This version reduces mutex contention by:
// - Batching updates from worker threads
// - Using local statistics per thread
// - Reducing I/O operations under mutex
// ============================================================================

const std = @import("std");
const Grid = @import("grid.zig").Grid;
const GridSize = @import("grid.zig").GridSize;
const TotalCells = @import("grid.zig").TotalCells;

// Local statistics for each worker thread (no synchronization needed)
pub const LocalStats = struct {
    games_played: u64 = 0,
    best_score: u32 = 0,
    solutions: std.ArrayList(Grid),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) LocalStats {
        return LocalStats{
            .solutions = std.ArrayList(Grid).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *LocalStats) void {
        self.solutions.deinit();
    }

    // Update local stats without any synchronization
    pub fn updateLocalScore(self: *LocalStats, score: u32, grid: *const Grid) void {
        self.games_played += 1;

        if (score > self.best_score) {
            self.best_score = score;
        }

        // Store perfect solutions locally
        if (score == TotalCells) {
            self.solutions.append(grid.*) catch {}; // Ignore allocation failures for now
        }
    }

    // Periodically flush to global state (much less frequent)
    pub fn shouldFlush(self: *const LocalStats) bool {
        return self.games_played % 10000 == 0; // Flush every 10k games
    }
};

// Optimized shared state with reduced contention
pub const SharedState = struct {
    mutex: std.Thread.Mutex,
    global_best_score: u32,
    total_games_played: u64,
    total_solutions_found: u64,

    pub fn init() SharedState {
        return SharedState{
            .mutex = std.Thread.Mutex{},
            .global_best_score = 0,
            .total_games_played = 0,
            .total_solutions_found = 0,
        };
    }

    // Legacy function for backwards compatibility (now deprecated)
    pub fn updateScore(self: *SharedState, score: u32, grid: *const Grid) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        self.total_games_played += 1;

        if (score > self.global_best_score) {
            self.global_best_score = score;
            std.debug.print("New best score: {} (Game #{})\n", .{ score, self.total_games_played });
        }

        if (score == TotalCells) {
            self.total_solutions_found += 1;
            std.debug.print("*** PERFECT SOLUTION FOUND! (Solution #{}) ***\n", .{self.total_solutions_found});

            // Save the solution to a file
            const hash = grid.hash();
            const filename = std.fmt.allocPrintZ(std.heap.page_allocator, "solution_{x}.txt", .{hash}) catch return;
            defer std.heap.page_allocator.free(filename);

            grid.saveSolutionToFile(filename) catch |err| {
                std.debug.print("Error saving solution: {}\n", .{err});
            };

            grid.print();
            std.debug.print("\n");
        }
    }

    // Batch update from local stats (called much less frequently)
    pub fn flushLocalStats(self: *SharedState, local_stats: *LocalStats) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        // Update global counters
        self.total_games_played += local_stats.games_played;

        // Check for new global best
        if (local_stats.best_score > self.global_best_score) {
            self.global_best_score = local_stats.best_score;
            std.debug.print("New global best score: {} (Total games: {})\n", .{ self.global_best_score, self.total_games_played });
        }

        // Process solutions found
        for (local_stats.solutions.items) |solution| {
            self.total_solutions_found += 1;
            std.debug.print("*** PERFECT SOLUTION FOUND! (Solution #{}) ***\n", .{self.total_solutions_found});

            // Save solution asynchronously or queue for later processing
            self.saveSolutionAsync(&solution) catch |err| {
                std.debug.print("Error saving solution: {}\n", .{err});
            };
        }

        // Reset local stats
        local_stats.games_played = 0;
        local_stats.best_score = 0;
        local_stats.solutions.clearAndFree();
    }

    fn saveSolutionAsync(self: *SharedState, grid: *const Grid) !void {
        _ = self; // Mark parameter as used

        // TODO: Implement async file saving or queue for background thread
        // For now, just do immediate save without grid printing
        const hash = grid.hash();
        const filename = try std.fmt.allocPrintZ(std.heap.page_allocator, "solution_{x}.txt", .{hash});
        defer std.heap.page_allocator.free(filename);

        try grid.saveSolutionToFile(filename);
    }

    pub fn getStats(self: *SharedState) struct { best_score: u32, games_played: u64, solutions_found: u64 } {
        self.mutex.lock();
        defer self.mutex.unlock();
        return .{
            .best_score = self.global_best_score,
            .games_played = self.total_games_played,
            .solutions_found = self.total_solutions_found,
        };
    }
};
