# Changelog

All notable changes to the 100 Numbers Game Solver will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0]

### Added
- 🔄 **Cyclic Solution Detection**: Automatic detection of solutions where the last position can legally move back to the first
- 🎯 **Path Tracking**: Complete move history tracking for all solutions enabling advanced analysis
- 🚀 **Comprehensive Variant Generation**: Generate up to 400 unique variants for cyclic solutions (100 shifts × 4 orientations)
- 📊 **Smart Solution Categorization**: Automatic differentiation between regular (4 variants) and cyclic (400 variants) solutions
- 🔍 **Legal Move Validation**: Enhanced move validation specifically for cyclic analysis
- 📁 **Enhanced File Naming**: Cyclic solutions saved with `solution_c_` prefix for easy identification

### Changed
- **Solution Storage**: Upgraded from fixed 4 orientations to intelligent variant generation based on solution type
- **Grid Structure**: Enhanced with path tracking array for comprehensive move history
- **Performance Monitoring**: Updated output to reflect cyclic solution detection capabilities
- **Documentation**: Comprehensive updates to README.md with cyclic solution explanations and examples

### Enhanced
- **Mathematical Analysis**: Solutions now provide maximum possible variant coverage for research purposes
- **Memory Efficiency**: Path tracking implemented with minimal memory overhead
- **User Experience**: Clear console output distinguishing between regular and cyclic solution discoveries

## [1.0.7] - 2025-05-29

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.0.6] - 2025-05-29

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.0.5] - 2025-05-29

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.0.4] - 2025-05-29

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.0.3] - 2025-05-29

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.0.2] - 2025-05-28

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.0.0] - 2025-05-28

### Added
- Comprehensive CI/CD pipeline with GitHub Actions
- Automated cross-platform releases for Windows, Linux, and macOS
- Local build scripts for cross-platform development (`scripts/build-all.ps1`, `scripts/build-all.sh`)
- Comprehensive test suite with 38 tests covering all critical functionality
- GitHub issue and pull request templates
- Dependabot configuration for automated dependency updates
- Contributing guidelines and community standards

### Enhanced
- Improved hash function for better collision resistance
- Enhanced README with CI/CD documentation and usage examples
- Better error handling and test coverage
- Mock I/O tests to prevent file writes during testing

### Technical
- **CI/CD Pipeline**: Automated testing on Ubuntu, Windows, and macOS
- **Cross-compilation**: Support for x86_64 and ARM64 architectures
- **Test Coverage**: 100% test pass rate with comprehensive validation
- **Build Optimization**: Release builds with `-Doptimize=ReleaseFast`
- **Quality Gates**: All releases pass full test suite and cross-compilation checks

## [1.0.0] - 2024-XX-XX

### Added
- Initial release of the 100 Numbers Game Solver
- High-performance multithreaded Monte Carlo simulation
- Automatic perfect solution detection and saving
- Cross-platform support (Windows, Linux, macOS)
- Real-time performance monitoring and statistics
- Hash-based solution deduplication across 4 orientations

### Features
- **Performance**: Up to 5.9M games/second on high-end systems
- **Scalability**: Linear scaling with CPU core count
- **Efficiency**: 99.9% reduction in mutex contention through batching
- **Reliability**: Thread-safe shared state management
- **Usability**: Automatic solution file management

### Architecture
- **Modular Design**: Separated into logical modules (grid, worker, shared_state)
- **Memory Efficient**: Minimal memory usage per thread (~1KB grid state)
- **Cache Friendly**: Optimized data structures for performance
- **Error Resilient**: Graceful handling of edge cases and errors

### Supported Platforms
- Windows x86_64
- Linux x86_64
- Linux ARM64 (aarch64)
- macOS Intel (x86_64)
- macOS Apple Silicon (aarch64)

### Performance Benchmarks
- **Single-threaded**: ~150,000 games/second
- **24-core system**: ~5,900,000 games/second (396% efficiency)
- **Memory usage**: <1KB per thread
- **Solution detection**: Automatic with 4-orientation deduplication

### Game Implementation
- **Accurate Rules**: Faithful implementation of 100 Numbers Game mechanics
- **Move Validation**: Proper validation of 3-cell orthogonal and 2-cell diagonal moves
- **Grid Management**: Efficient 10×10 grid with occupied cell tracking
- **Scoring System**: Accurate tracking of maximum achieved score (1-100)

### Development
- **Language**: Zig 0.14.1
- **Build System**: Native Zig build with optimization options
- **Testing**: Unit tests and integration tests
- **Documentation**: Comprehensive README with usage examples

---

## Version History Summary

### Performance Evolution
- **v0.1**: Single-threaded, ~150k games/sec
- **v0.5**: Basic multithreading, ~1.9M games/sec (53% efficiency)
- **v1.0**: Optimized batching, ~5.9M games/sec (396% efficiency)

### Architecture Evolution
- **v0.1**: Monolithic single file
- **v0.5**: Basic module separation
- **v1.0**: Full modular architecture with comprehensive testing

### Testing Evolution
- **v0.1**: No automated tests
- **v0.5**: Basic unit tests
- **v1.0**: 38 comprehensive tests covering all functionality

## Contributing

For information about contributing to this project, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
