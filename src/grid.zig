// ============================================================================
// Grid and Move structures for the 100 Numbers Game
//
// This module contains the core game logic including:
// - Move structure for representing game moves
// - Grid structure for the 10x10 game board
// - All grid manipulation functions (fill, validate, print, etc.)
// - Game playing logic and file I/O operations
// ============================================================================

const std = @import("std");

pub const GridSize = 10; // Defines the size of the grid (10x10).
pub const TotalCells = GridSize * GridSize; // Calculates the total number of cells in the grid.

pub const Move = struct { // Defines a structure to represent a move.
    x: i32, // The change in the x-coordinate for the move.
    y: i32, // The change in the y-coordinate for the move.
};

pub const moves = [_]Move{ // Defines an array of possible moves.
    .{ .x = 3, .y = 0 }, .{ .x = -3, .y = 0 }, .{ .x = 0, .y = 3 }, .{ .x = 0, .y = -3 }, // Horizontal and vertical jumps of three cells.
    .{ .x = 2, .y = 2 }, .{ .x = 2, .y = -2 }, .{ .x = -2, .y = 2 }, .{ .x = -2, .y = -2 }, // Diagonal jumps of two cells.
};

pub const Grid = struct { // Defines a structure to represent the game grid.
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
