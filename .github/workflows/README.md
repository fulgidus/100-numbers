# GitHub Actions Configuration

This document describes the CI/CD setup for the 100 Numbers Game Solver project.

## Workflows

### 1. CI/CD Pipeline (`ci.yml`)
- **Trigger**: Push to main/master, Pull Requests
- **Purpose**: Testing, building, and automated daily releases
- **Platforms**: Ubuntu, Windows, macOS
- **Outputs**: Cross-platform binaries, automated releases

### 2. Release Pipeline (`release.yml`)
- **Trigger**: Git tags (v*)
- **Purpose**: Manual tagged releases
- **Platforms**: All supported targets
- **Outputs**: Tagged release with optimized binaries

## Required Secrets

The workflows use the following GitHub secrets:

### `GITHUB_TOKEN`
- **Type**: Auto-generated GitHub token
- **Purpose**: Create releases, upload artifacts
- **Scope**: Contents (write), Metadata (read)
- **Configuration**: Automatically available, no setup required

## Supported Targets

| Platform            | Target           | Binary Name                      | Archive Format |
| ------------------- | ---------------- | -------------------------------- | -------------- |
| Windows x64         | `x86_64-windows` | `100-numbers-windows-x86_64.exe` | `.zip`         |
| Linux x64           | `x86_64-linux`   | `100-numbers-linux-x86_64`       | `.tar.gz`      |
| Linux ARM64         | `aarch64-linux`  | `100-numbers-linux-aarch64`      | `.tar.gz`      |
| macOS Intel         | `x86_64-macos`   | `100-numbers-macos-x86_64`       | `.tar.gz`      |
| macOS Apple Silicon | `aarch64-macos`  | `100-numbers-macos-aarch64`      | `.tar.gz`      |

## Build Configuration

### Zig Version
- **Version**: 0.14.1
- **Action**: `goto-bus-stop/setup-zig@v2`
- **Caching**: Automatic Zig installation caching

### Optimization
- **Debug Builds**: `-Doptimize=Debug` (CI testing)
- **Release Builds**: `-Doptimize=ReleaseFast` (releases)

### Test Suite
- **Command**: `zig build test`
- **Coverage**: 38 comprehensive tests
- **Areas**: Input validation, game logic, thread safety, memory management

## Artifact Management

### Retention
- **CI Artifacts**: 90 days
- **Release Artifacts**: Permanent (GitHub Releases)

### Naming Convention
- **Daily Releases**: `vYYYY.MM.DD-{commit_hash}`
- **Tagged Releases**: `v{major}.{minor}.{patch}`

### Archive Structure
```
# Unix platforms (.tar.gz)
100-numbers-{platform}/
└── 100-numbers-{platform}  # Executable with +x permissions

# Windows platform (.zip)  
100-numbers-windows-x86_64/
└── 100-numbers-windows-x86_64.exe  # Executable
```

## Pipeline Performance

### Expected Times
- **Testing Phase**: ~3-5 minutes per platform
- **Build Phase**: ~2-3 minutes per target
- **Release Creation**: ~1-2 minutes
- **Total Pipeline**: ~15-20 minutes

### Parallel Execution
- **Test Jobs**: Run in parallel across 3 platforms
- **Build Jobs**: Run in parallel across 5 targets
- **Dependencies**: Builds wait for successful tests

## Troubleshooting

### Common Issues

#### Build Failures
- **Zig Version Mismatch**: Ensure workflow uses Zig 0.14.1
- **Target Issues**: Verify target names match Zig's target naming
- **Path Issues**: Use relative paths for cross-platform compatibility

#### Test Failures
- **Platform-specific**: Check for OS-specific test failures
- **Race Conditions**: Thread safety tests may be sensitive to timing
- **Memory Issues**: Verify tests don't exceed memory limits

#### Release Issues
- **Permission Errors**: Ensure GITHUB_TOKEN has sufficient permissions
- **Artifact Size**: Monitor for excessively large binaries
- **Archive Corruption**: Verify archive creation commands

### Debug Commands

```bash
# Local testing
zig build test                    # Run all tests
zig build -Doptimize=ReleaseFast  # Test release build
zig build -Dtarget=x86_64-linux   # Test cross-compilation

# GitHub Actions debugging
# Add to workflow for debugging:
- name: Debug Environment
  run: |
    echo "Runner OS: ${{ runner.os }}"
    echo "GitHub Ref: ${{ github.ref }}"
    echo "Event Name: ${{ github.event_name }}"
    zig targets  # Show available targets
```

## Maintenance

### Dependencies
- **Dependabot**: Configured to update GitHub Actions weekly
- **Zig Updates**: Manual updates required in workflow files
- **Security**: Regular security scan via GitHub

### Monitoring
- **Build Status**: Monitor via GitHub Actions tab
- **Performance**: Track build times and artifact sizes
- **Failures**: Set up notifications for pipeline failures
