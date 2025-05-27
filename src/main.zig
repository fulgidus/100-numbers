// ============================================================================
// 100 Numbers Game Solver in Zig
//
// This program solves the "100 Numbers Game" on a 10x10 grid. The objective
// is to fill the grid with numbers from 1 to 100, starting from any cell,
// following specific movement rules:
// - Each move must jump two cells horizontally or vertically, or one cell
//   diagonally.
// - Moves cannot revisit any previously filled cell.
// - The goal is to fill all 100 cells without violating the movement rules.
//
// Each solution found is saved to a text file named using the hash of the
// solution grid, ensuring uniqueness and easy identification.
// ============================================================================

const std = @import("std"); // Imports the standard library.
const GridSize = 10; // Defines the size of the grid (10x10).
const TotalCells = GridSize * GridSize; // Calculates the total number of cells in the grid.

// Shared state for multithreading
const SharedState = struct {
    mutex: std.Thread.Mutex,
    best_score: u32,
    games_played: u64,
    solutions_found: u64,

    pub fn init() SharedState {
        return SharedState{
            .mutex = std.Thread.Mutex{},
            .best_score = 0,
            .games_played = 0,
            .solutions_found = 0,
        };
    }

    pub fn updateScore(self: *SharedState, score: u32, grid: *const Grid) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        self.games_played += 1;

        if (score > self.best_score) {
            self.best_score = score;
            std.debug.print("New best score: {} (Thread: {})\n", .{ score, std.Thread.getCurrentId() });
            grid.print();
        }

        if (score == TotalCells) {
            self.solutions_found += 1;
            std.debug.print("*** PERFECT SOLUTION FOUND! (Solution #{}) ***\n", .{self.solutions_found});
            self.saveSolution(grid) catch |err| {
                std.debug.print("Error saving perfect solution: {}\n", .{err});
            };
        }
    }

    fn saveSolution(self: *SharedState, grid: *const Grid) !void {
        _ = self; // Mark parameter as used
        // Save all 4 orientations
        const flipped_grid = grid.flip();
        const inverted_grid = grid.invert();
        const flipped_inverted_grid = flipped_grid.invert();

        const grids: [4]Grid = .{
            grid.*,
            inverted_grid,
            flipped_grid,
            flipped_inverted_grid,
        };

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

const Move = struct { // Defines a structure to represent a move.
    x: i32, // The change in the x-coordinate for the move.
    y: i32, // The change in the y-coordinate for the move.
};

const moves = [_]Move{ // Defines an array of possible moves.
    .{ .x = 3, .y = 0 }, .{ .x = -3, .y = 0 }, .{ .x = 0, .y = 3 }, .{ .x = 0, .y = -3 }, // Horizontal and vertical jumps of two cells.
    .{ .x = 2, .y = 2 }, .{ .x = 2, .y = -2 }, .{ .x = -2, .y = 2 }, .{ .x = -2, .y = -2 }, // Diagonal jumps of one cell.
};

const Grid = struct { // Defines a structure to represent the game grid.
    cells: [GridSize][GridSize]u8, // A 2D array to store the cell values.
    occupied_cells: [GridSize][GridSize]bool, // A 2D array to track if a cell is occupied.
    lastMove: Move, // Stores the last move made on the grid.
    filled: u32, // Stores the number of cells currently filled.

    pub fn init() Grid { // Defines a public function to initialize a new grid.
        return Grid{
            .cells = std.mem.zeroes([GridSize][GridSize]u8), // Initialize all cells to zero.
            .occupied_cells = std.mem.zeroes([GridSize][GridSize]bool), // Initialize all cells as unoccupied.
            .filled = 0, // Initialize filled counter to zero.
            .lastMove = .{ .x = 0, .y = 0 }, // Initialize last move to origin.
        };
    }

    pub fn isFull(self: *Grid) bool { // Defines a public function to check if the grid is full.
        return self.filled == TotalCells; // Returns true if the number of filled cells equals the total number of cells.
    }

    pub fn isValidMove(self: *Grid, x: i32, y: i32) bool { // Defines a public function to check if a move to (x, y) is valid.
        return x >= 0 and x < GridSize and y >= 0 and y < GridSize and !self.occupied_cells[@as(usize, @intCast(y))][@as(usize, @intCast(x))]; // Returns true if (x,y) is within bounds and the target cell is not occupied.
    }

    pub fn fillCell(self: *Grid, x: i32, y: i32) void { // Defines a public function to fill a cell with a value.
        const moveNumber: u8 = @intCast(self.filled + 1); // Calculates the move number based on the current filled count.
        self.cells[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = moveNumber; // Sets the value of the cell at (x, y).
        self.occupied_cells[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = true; // Marks the cell as occupied.
        self.filled = moveNumber; // Increments the count of filled cells.
        self.lastMove = .{ .x = x, .y = y }; // Updates the last move to the current cell.
    }
    pub fn makeRandomMove(self: *Grid) !void { // Defines a public function to make a random valid move.
        var valid_moves: [moves.len]Move = undefined; // Array to store valid moves from current position.
        var valid_count: usize = 0; // Counter for number of valid moves found.

        // Check all possible moves from the current position
        for (moves) |move| { // Iterate through all defined move patterns.
            const new_x = self.lastMove.x + move.x; // Calculate new x position.
            const new_y = self.lastMove.y + move.y; // Calculate new y position.
            if (self.isValidMove(new_x, new_y)) { // Check if this move is valid.
                valid_moves[valid_count] = .{ .x = new_x, .y = new_y }; // Store the valid move.
                valid_count += 1; // Increment valid move counter.
            }
        }

        if (valid_count == 0) { // If no valid moves are available.
            return error.NoValidMoves; // Return an error indicating no moves possible.
        }

        // Select a random valid move
        const random_index = std.crypto.random.int(u32) % @as(u32, @intCast(valid_count)); // Generate random index within valid moves.
        const chosen_move = valid_moves[@as(usize, @intCast(random_index))]; // Select the random valid move.
        self.fillCell(chosen_move.x, chosen_move.y); // Fill the chosen cell with next number.
    }
    pub fn playRandomGame(self: *Grid) !u32 { // Defines a public function to play a full game with random moves.
        // Start from a random cell
        const start_x = @as(i32, @intCast(std.crypto.random.int(u32) % GridSize)); // Generate random starting x-coordinate.
        const start_y = @as(i32, @intCast(std.crypto.random.int(u32) % GridSize)); // Generate random starting y-coordinate.
        self.fillCell(start_x, start_y); // Starts the game by filling the random starting cell with 1.
        while (!self.isFull()) { // Loops until the grid is full.
            self.makeRandomMove() catch |err| switch (err) { // Makes a random move, handling errors.
                error.NoValidMoves => { // If no valid moves are available.
                    //std.debug.print("Game ended at move {}: No valid moves available!\n", .{self.filled}); // Print game end message.
                    return self.filled; // Exit the function early.
                },
                else => return err, // Propagate other errors.
            };
        }
        return self.filled; // Return the total number of filled cells when the game ends.
    }
    pub fn print(self: *const Grid) void { // Defines a public function to print the grid.
        const stdout = std.io.getStdOut().writer(); // Gets a writer for standard output.
        stdout.print("Score: {}\n", .{self.filled}) catch {}; // Prints the current score (number of filled cells), ignoring errors.
        stdout.print("Grid:\n", .{}) catch {}; // Prints a header for the grid, ignoring errors.
        for (0..GridSize) |y| { // Iterates over each row of the grid.
            for (0..GridSize) |x| { // Iterates over each column in the current row.
                stdout.print("{:>3} ", .{self.cells[y][x]}) catch {}; // Prints the cell value, right-aligned in 3 spaces, ignoring errors.
            }
            stdout.print("\n", .{}) catch {}; // Prints a newline character at the end of each row, ignoring errors.
        }
        stdout.print("\n", .{}) catch {}; // Prints an extra newline character after the grid, ignoring errors.
    }
    pub fn hash(self: *const Grid) u64 { // Defines a public function to compute a hash of the grid.
        var hasher = std.hash.Wyhash.init(0); // Initializes a Wyhash hasher with seed 0.
        hasher.update(std.mem.asBytes(&self.cells)); // Updates the hasher with the grid cell data as bytes.
        return hasher.final(); // Returns the final hash value.
    }
    pub fn flip(self: *const Grid) Grid { // Defines a public function to flip the grid horizontally.
        var flipped = self.*; // Creates a copy of the grid to modify.
        for (0..GridSize) |i| { // Iterates over all rows.
            for (0..GridSize) |j| { // Iterates over all columns.
                // Flip horizontally: swap column j with column (GridSize - 1 - j)
                flipped.cells[i][j] = self.cells[i][GridSize - 1 - j]; // Copy from the mirrored column.
            }
        }
        return flipped; // Returns the modified grid with flipped columns.
    }
    pub fn invert(self: *const Grid) Grid { // Defines a public function to invert the grid.
        var inverted = self.*; // Creates a copy of the grid to modify.
        for (0..GridSize) |i| { // Iterates over all rows.
            for (0..GridSize) |j| { // Iterates over all columns.
                // Invert: swap row i with row (GridSize - 1 - i)
                inverted.cells[i][j] = self.cells[GridSize - 1 - i][j]; // Copy from the mirrored row.
            }
        }
        return inverted; // Returns the modified grid with flipped rows.
    }
    pub fn saveSolutionToFile(self: *const Grid, filename: []const u8) !void { // Defines a public function to save the grid to a file.
        const file = std.fs.cwd().createFile(filename, .{}) catch |err| { // Creates a file with the given filename.
            return err; // Returns an error if file creation fails.
        };
        defer file.close(); // Ensures the file is closed after writing.

        for (0..GridSize) |y| { // Iterates over each row of the grid.
            for (0..GridSize) |x| { // Iterates over each column in the current row.
                const cell_str = try std.fmt.allocPrintZ(std.heap.page_allocator, "{:>3} ", .{self.cells[y][x]}); // Allocate string for cell value.
                defer std.heap.page_allocator.free(cell_str); // Free the allocated memory.
                try file.writeAll(cell_str); // Writes each cell value to the file.
            }
            try file.writeAll("\n"); // Writes a newline character at the end of each row.
        }
    }
};

// Worker function for each thread
fn workerThread(shared_state: *SharedState) void {
    var grid = Grid.init();

    while (true) {
        grid = Grid.init(); // Reset grid for new game

        const score = grid.playRandomGame() catch |err| switch (err) {
            else => {
                // Continue on error - don't spam console
                continue;
            },
        };

        shared_state.updateScore(score, &grid);
    }
}

// Performance monitoring thread
fn performanceMonitor(shared_state: *SharedState) void {
    var last_games_count: u64 = 0;
    var last_report_time = std.time.milliTimestamp();
    const report_interval_ms: i64 = 5000; // Report every 5 seconds

    while (true) {
        std.time.sleep(1_000_000_000); // Sleep for 1 second (nanoseconds)

        const current_time = std.time.milliTimestamp();
        if (current_time - last_report_time >= report_interval_ms) {
            const stats = shared_state.getStats();
            const games_in_interval = stats.games_played - last_games_count;
            const time_elapsed_sec = @as(f64, @floatFromInt(current_time - last_report_time)) / 1000.0;
            const games_per_second = @as(f64, @floatFromInt(games_in_interval)) / time_elapsed_sec;

            std.debug.print("Performance: {d:.1} games/second | Best: {} | Perfect solutions: {}\n", .{ games_per_second, stats.best_score, stats.solutions_found });

            last_report_time = current_time;
            last_games_count = stats.games_played;
        }
    }
}

pub fn main() !void {
    std.debug.print("*** Starting 100 Numbers Game Solver (Multithreaded) ***\n", .{});
    std.debug.print("Press Ctrl+C to stop\n\n", .{});

    // Get number of CPU cores
    const cpu_count = std.Thread.getCpuCount() catch 4; // Default to 4 if detection fails
    std.debug.print("Using {} threads (CPU cores detected)\n", .{cpu_count});

    // Initialize shared state
    var shared_state = SharedState.init();

    // Create thread pool
    var threads = std.ArrayList(std.Thread).init(std.heap.page_allocator);
    defer threads.deinit();

    // Start worker threads
    for (0..cpu_count) |i| {
        const thread = try std.Thread.spawn(.{}, workerThread, .{&shared_state});
        try threads.append(thread);
        std.debug.print("Started worker thread #{}\n", .{i + 1});
    }

    // Start performance monitoring thread
    const perf_thread = try std.Thread.spawn(.{}, performanceMonitor, .{&shared_state});
    std.debug.print("Started performance monitor thread\n\n", .{});

    // Wait for threads to complete (they run forever until Ctrl+C)
    for (threads.items) |thread| {
        thread.join();
    }
    perf_thread.join();
}
