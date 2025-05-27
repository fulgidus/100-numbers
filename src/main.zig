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
    lastMove: Move, // Stores the last move made on the grid.
    filled: u32, // Stores the number of cells currently filled.

    pub fn init() Grid { // Defines a public function to initialize a new grid.
        return Grid{
            .cells = std.mem.zeroes([GridSize][GridSize]u8), // Initialize all cells to zero.
            .filled = 0, // Initialize filled counter to zero.
            .lastMove = .{ .x = 0, .y = 0 }, // Initialize last move to origin.
        };
    }

    pub fn isFull(self: *const Grid) bool { // Defines a public function to check if the grid is full.
        return self.filled == TotalCells; // Returns true if the number of filled cells equals the total number of cells.
    }

    pub fn isValidMove(self: *const Grid, x: i32, y: i32) bool { // Defines a public function to check if a move to (x, y) is valid.
        return x >= 0 and x < GridSize and y >= 0 and y < GridSize and self.cells[@as(usize, @intCast(y))][@as(usize, @intCast(x))] == 0; // Returns true if (x,y) is within bounds and the target cell is empty (0).
    }

    pub fn fillCell(self: *Grid, x: i32, y: i32) void { // Defines a public function to fill a cell with a value.
        const moveNumber: u8 = @intCast(self.filled + 1); // Calculates the move number based on the current filled count.
        self.cells[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = moveNumber; // Sets the value of the cell at (x, y).
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
    pub fn print(self: *Grid) void { // Defines a public function to print the grid.
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
};
pub fn main() !void { // Defines the main function of the program.
    var score: u32 = 0;
    var best_score: u32 = 0; // Initializes the best score to zero.
    var grid = Grid.init();

    // Performance tracking variables
    var games_played: u64 = 0; // Total number of games played
    var last_report_time = std.time.milliTimestamp(); // Last time we reported performance
    var last_games_count: u64 = 0; // Games count at last report
    const report_interval_ms: i64 = 5000; // Report every 5 seconds

    while (score < 100) { // Loops until a solution is obtained
        grid = Grid.init(); // Initializes a new grid.
        games_played += 1; // Increment games counter
        score = grid.playRandomGame() catch |err| switch (err) { // Starts playing the game, catching any errors.
            else => {
                std.debug.print("Error occurred: {}\n", .{err}); // Prints an error message if an error occurs.
                continue; // Skip to next iteration instead of assigning a value
            },
        };

        // Check if it's time to report performance
        const current_time = std.time.milliTimestamp();
        if (current_time - last_report_time >= report_interval_ms) {
            const games_in_interval = games_played - last_games_count;
            const time_elapsed_sec = @as(f64, @floatFromInt(current_time - last_report_time)) / 1000.0;
            const games_per_second = @as(f64, @floatFromInt(games_in_interval)) / time_elapsed_sec;

            std.debug.print("Performance: {d:.1} games/second (Best: {})\n", .{ games_per_second, best_score });

            last_report_time = current_time;
            last_games_count = games_played;
        }

        if (score > best_score) { // If the current score is better than the best score.
            best_score = score; // Update the best score.
            grid.print();
        }
    }

    // Save the grid to a file named by its hash
    var hasher = std.hash.Wyhash.init(0); // Initializes a Wyhash hasher with seed 0.
    hasher.update(std.mem.asBytes(&grid.cells)); // Updates the hasher with the grid cell data as bytes.
    const hash = hasher.final(); // Finalizes the hash calculation.
    const filename = std.fmt.allocPrintZ(std.heap.page_allocator, "solution_{x}.txt", .{hash}) catch unreachable; // Creates a filename string using the hash, allocating memory; catches unreachable errors.
    const file = try std.fs.cwd().createFile(filename, .{}); // Creates a new file with the generated filename for writing, propagating errors.
    defer file.close(); // Ensures the file is closed when the function exits.

    for (0..GridSize) |y| { // Iterates over each row of the grid.
        for (0..GridSize) |x| { // Iterates over each column in the current row.
            const cell_str = try std.fmt.allocPrintZ(std.heap.page_allocator, "{:>3} ", .{grid.cells[y][x]}); // Creates a formatted string for the cell value.
            try file.writeAll(cell_str); // Writes the cell value (right-aligned in 3 spaces) to the file, propagating errors.
        }
        try file.writeAll("\n"); // Writes a newline character to the file at the end of each row, propagating errors.
    }
}
