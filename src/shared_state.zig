// ============================================================================
// Shared State Module for 100 Numbers Game Solver
//
// This module manages the shared state between worker threads, including:
// - Best score tracking across all threads
// - Game statistics (games played, solutions found)
// - Thread-safe access through mutex protection
// - Solution saving functionality for perfect games
// ============================================================================

const std = @import("std");
const Grid = @import("grid.zig").Grid;
const GridSize = @import("grid.zig").GridSize;
const TotalCells = @import("grid.zig").TotalCells;

// Shared state structure for multithreading coordination
pub const SharedState = struct {
    mutex: std.Thread.Mutex, // Mutex for thread-safe access to shared data
    best_score: u32, // Highest score achieved across all threads
    games_played: u64, // Total number of games played by all threads
    solutions_found: u64, // Total number of perfect solutions found

    // Initialize shared state with default values
    pub fn init() SharedState {
        return SharedState{
            .mutex = std.Thread.Mutex{},
            .best_score = 0,
            .games_played = 0,
            .solutions_found = 0,
        };
    }

    // Thread-safe method to update score and handle new records
    pub fn updateScore(self: *SharedState, score: u32, grid: *const Grid) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        self.games_played += 1;

        // Check if this is a new best score
        if (score > self.best_score) {
            self.best_score = score;
            std.debug.print("New best score: {} (Thread: {})\n", .{ score, std.Thread.getCurrentId() });
            grid.print();
        }

        // Check if this is a perfect solution (100/100)
        if (score == TotalCells) {
            self.solutions_found += 1;
            std.debug.print("*** PERFECT SOLUTION FOUND! (Solution #{}) ***\n", .{self.solutions_found});
            self.saveSolution(grid) catch |err| {
                std.debug.print("Error saving perfect solution: {}\n", .{err});
            };
        }
    }

    // Save a perfect solution to files (all 4 orientations for uniqueness)
    fn saveSolution(self: *SharedState, grid: *const Grid) !void {
        _ = self; // Mark parameter as used

        // Generate all 4 possible orientations of the solution
        const flipped_grid = grid.flip();
        const inverted_grid = grid.invert();
        const flipped_inverted_grid = flipped_grid.invert();

        const grids: [4]Grid = .{
            grid.*,
            inverted_grid,
            flipped_grid,
            flipped_inverted_grid,
        };

        // Save each orientation as a separate file
        for (grids) |g| {
            const hash = g.hash();
            const filename = std.fmt.allocPrintZ(std.heap.page_allocator, "solution_{x}.txt", .{hash}) catch |err| {
                std.debug.print("Error allocating filename: {}\n", .{err});
                return err;
            };
            defer std.heap.page_allocator.free(filename);

            try g.saveSolutionToFile(filename);
            std.debug.print("Solution saved to: {s}\n", .{filename});
        }
    }

    // Thread-safe method to retrieve current statistics
    pub fn getStats(self: *SharedState) struct { best_score: u32, games_played: u64, solutions_found: u64 } {
        self.mutex.lock();
        defer self.mutex.unlock();
        return .{
            .best_score = self.best_score,
            .games_played = self.games_played,
            .solutions_found = self.solutions_found,
        };
    }
};
