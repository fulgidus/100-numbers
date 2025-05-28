# Contributing to 100 Numbers Game Solver

Thank you for your interest in contributing to the 100 Numbers Game Solver! This document provides guidelines and information for contributors.

## 🎯 Project Overview

This is a high-performance multithreaded solver for the 100 Numbers Game, written in Zig. The project focuses on:

- **Performance**: Maximizing game simulation throughput
- **Correctness**: Reliable game logic and thread safety
- **Cross-platform**: Support for Windows, Linux, and macOS
- **Code Quality**: Clean, well-tested, maintainable code

## 🛠️ Development Setup

### Prerequisites

- **Zig 0.14.1** or later
- **Git** for version control
- **PowerShell** (Windows) or **Bash** (Linux/macOS) for build scripts

### Setting Up the Development Environment

1. **Clone the repository**:
   ```bash
   git clone https://github.com/aless/100-numbers.git
   cd 100-numbers
   ```

2. **Verify Zig installation**:
   ```bash
   zig version
   # Should output: 0.14.1 or later
   ```

3. **Run the test suite**:
   ```bash
   zig build test
   ```

4. **Build and test the application**:
   ```bash
   zig build
   ./zig-out/bin/100
   ```

## 🧪 Testing

### Running Tests

```bash
# Run all tests (unit + comprehensive)
zig build test

# Run only comprehensive tests  
zig build test-comprehensive

# Cross-platform build testing
./scripts/build-all.sh --test  # Linux/macOS
.\scripts\build-all-clean.ps1 -Test  # Windows
```

### Test Categories

The project has a comprehensive test suite covering:

- **Input Validation** (8 tests): Boundary checking, coordinate validation
- **Game Logic** (8 tests): Move generation, game flow, consistency
- **Thread Safety** (6 tests): Concurrent access, synchronization
- **Memory Management** (6 tests): Hash functions, transformations
- **File I/O** (6 tests): Solution saving, mock operations
- **Edge Cases** (4 tests): Boundary conditions, error handling

### Writing Tests

When adding new functionality:

1. Add tests to `src/tests.zig`
2. Follow the existing test naming convention: `test "descriptive_name"`
3. Use meaningful assertions with descriptive error messages
4. Test both success and failure cases
5. Ensure thread safety for concurrent operations

Example test structure:
```zig
test "feature_description" {
    const allocator = std.testing.allocator;
    
    // Setup
    var grid = Grid.init();
    
    // Exercise
    const result = grid.someOperation();
    
    // Verify
    try std.testing.expect(result == expected_value);
    try std.testing.expectEqual(expected_grid_state, grid.some_field);
}
```

## 🏗️ Code Structure

### Architecture

```
src/
├── main.zig          # Application entry point, thread coordination
├── grid.zig          # Core game logic, Grid struct, move validation
├── shared_state.zig  # Thread-safe state management, statistics
├── worker.zig        # Worker threads, performance monitoring  
└── tests.zig         # Comprehensive test suite
```

### Coding Standards

#### Zig Style Guidelines

- **Naming**: `snake_case` for functions/variables, `PascalCase` for types
- **Indentation**: 4 spaces, no tabs
- **Line Length**: Prefer <100 characters, hard limit at 120
- **Comments**: Document public APIs, complex algorithms, and non-obvious code

#### Code Organization

- **Functions**: Keep functions focused and under 50 lines when possible
- **Error Handling**: Use Zig's error handling (`!` and `catch`)
- **Memory Management**: Prefer stack allocation, document heap usage
- **Threading**: Use mutexes for shared state, minimize lock contention

#### Performance Considerations

- **Hot Paths**: Profile and optimize critical game simulation loops
- **Memory Usage**: Minimize allocations in game simulation
- **Cache Efficiency**: Consider data layout for cache-friendly access
- **Batch Operations**: Reduce mutex contention with batching

## 📝 Contribution Process

### 1. Issue Discussion

Before starting work:
- Check existing issues and pull requests
- For bugs: Provide reproduction steps and environment details
- For features: Discuss the approach and design first

### 2. Development Workflow

1. **Fork** the repository
2. **Create a feature branch**: `git checkout -b feature/description`
3. **Make changes** following coding standards
4. **Add tests** for new functionality
5. **Run the full test suite**: `zig build test`
6. **Test cross-platform builds**: Use build scripts
7. **Commit** with descriptive messages
8. **Push** to your fork
9. **Create a pull request**

### 3. Pull Request Guidelines

#### PR Title Format
```
[Type]: Brief description

Examples:
feat: Add new hash-based solution deduplication
fix: Resolve race condition in statistics reporting
perf: Optimize grid transformation operations
test: Add comprehensive thread safety tests
docs: Update build instructions for Zig 0.14.1
```

#### PR Description Template
Use the provided pull request template that includes:
- Description of changes
- Related issue links
- Testing checklist
- Performance impact assessment
- Platform testing verification

### 4. Code Review Process

All contributions go through code review:

- **Automated Checks**: CI pipeline runs tests and builds
- **Code Quality**: Review for style, performance, and maintainability
- **Testing**: Verify adequate test coverage
- **Documentation**: Ensure changes are properly documented

## 🚀 Performance Contributions

### Optimization Guidelines

When contributing performance improvements:

1. **Measure First**: Profile existing performance
2. **Targeted Changes**: Focus on hot paths identified by profiling
3. **Benchmark**: Compare before/after performance
4. **Test Thoroughly**: Ensure correctness is maintained
5. **Document**: Explain the optimization technique

### Performance Testing

```bash
# Benchmark current performance
./zig-out/bin/100

# Test optimized build
zig build -Doptimize=ReleaseFast
./zig-out/bin/100
```

Monitor key metrics:
- Games per second throughput
- CPU core utilization efficiency
- Memory usage patterns
- Solution detection accuracy

## 🐛 Bug Reports

### Issue Template

When reporting bugs, include:

- **Environment**: OS, Zig version, hardware specs
- **Reproduction Steps**: Minimal steps to reproduce
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Logs/Output**: Relevant error messages or output
- **Additional Context**: Screenshots, related issues

### Common Issues

- **Build Failures**: Check Zig version compatibility
- **Test Failures**: May indicate platform-specific issues
- **Performance Issues**: Could be hardware or configuration related
- **Thread Safety**: Race conditions may be intermittent

## 📚 Documentation

### What to Document

- **Public APIs**: All public functions and types
- **Complex Algorithms**: Game logic, optimization techniques
- **Configuration**: Build options, environment variables
- **Examples**: Usage examples for new features

### Documentation Standards

- Use clear, concise language
- Include code examples where helpful
- Keep documentation up-to-date with code changes
- Document performance characteristics for optimization features

## 🤝 Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers learn and contribute
- Celebrate diverse perspectives and approaches

### Communication

- **Issues**: For bug reports and feature requests
- **Discussions**: For questions and general discussion
- **Pull Requests**: For code contributions

## 🏆 Recognition

Contributors are recognized through:
- GitHub contributor statistics
- Mention in release notes for significant contributions
- Attribution in code comments for major features/fixes

## 📞 Getting Help

If you need help:
1. Check existing documentation and issues
2. Create a new issue with the "question" label
3. Provide context about what you're trying to achieve

Thank you for contributing to the 100 Numbers Game Solver! 🎯
