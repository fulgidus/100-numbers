# 100 Numbers Game Solver - Release Script
# This script helps create tagged releases with proper versioning

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,

    [string]$Message = "",
    [switch]$DryRun = $false,
    [switch]$Force = $false
)

# Validate version format (semantic versioning)
if ($Version -notmatch '^v?\d+\.\d+\.\d+(-[a-zA-Z0-9]+)?$') {
    Write-Host "Error: Invalid version format. Use semantic versioning (e.g., v1.0.0, 1.2.3, v2.0.0-beta1)" -ForegroundColor Red
    exit 1
}

# Ensure version starts with 'v'
if (-not $Version.StartsWith('v')) {
    $Version = "v$Version"
}

Write-Host "100 Numbers Game Solver - Release Creator" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Yellow

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Host "Error: Not in a git repository" -ForegroundColor Red
    exit 1
}

# Check if tag already exists
$tagExists = git tag -l $Version
if ($tagExists -and -not $Force) {
    Write-Host "Error: Tag $Version already exists. Use -Force to overwrite." -ForegroundColor Red
    exit 1
}

# Check for uncommitted changes
$status = git status --porcelain
if ($status -and -not $Force) {
    Write-Host "Error: There are uncommitted changes. Commit them first or use -Force." -ForegroundColor Red
    Write-Host "Uncommitted files:" -ForegroundColor Yellow
    $status | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    exit 1
}

# Run tests before release
Write-Host "Running comprehensive test suite..." -ForegroundColor Yellow
if ($DryRun) {
    Write-Host "[DRY RUN] Would run: zig build test" -ForegroundColor Gray
} else {
    zig build test
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Tests failed! Fix tests before creating release." -ForegroundColor Red
        exit 1
    }
    Write-Host "All tests passed!" -ForegroundColor Green
}

# Build all platforms to ensure they work
Write-Host "Testing cross-platform builds..." -ForegroundColor Yellow
if ($DryRun) {
    Write-Host "[DRY RUN] Would run cross-platform build test" -ForegroundColor Gray
} else {
    & ".\scripts\build-all-clean.ps1" -BuildType "ReleaseFast"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Cross-platform build failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "All platforms built successfully!" -ForegroundColor Green
}

# Update CHANGELOG.md
Write-Host "Updating CHANGELOG.md..." -ForegroundColor Yellow
$changelogPath = "CHANGELOG.md"
if (Test-Path $changelogPath) {
    $changelog = Get-Content $changelogPath -Raw
    $today = Get-Date -Format "yyyy-MM-dd"

    # Replace [Unreleased] with the new version
    $newChangelog = $changelog -replace '\[Unreleased\]', "[$($Version.Substring(1))] - $today"

    # Add new [Unreleased] section
    $unreleasedSection = @"
## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [$($Version.Substring(1))] - $today
"@

    $newChangelog = $newChangelog -replace "## \[$($Version.Substring(1))\] - $today", $unreleasedSection

    if ($DryRun) {
        Write-Host "[DRY RUN] Would update CHANGELOG.md" -ForegroundColor Gray
    } else {
        Set-Content -Path $changelogPath -Value $newChangelog -NoNewline
        Write-Host "CHANGELOG.md updated" -ForegroundColor Green
    }
} else {
    Write-Host "Warning: CHANGELOG.md not found" -ForegroundColor Yellow
}

# Generate release message
if (-not $Message) {
    $Message = "Release $Version

This release includes:
- Performance improvements and bug fixes
- Cross-platform builds for Windows, Linux, and macOS
- Comprehensive test suite validation

See CHANGELOG.md for detailed changes.

Download the appropriate binary for your platform:
- Windows: 100-numbers-windows-x86_64.zip
- Linux x64: 100-numbers-linux-x86_64.tar.gz
- Linux ARM64: 100-numbers-linux-aarch64.tar.gz
- macOS Intel: 100-numbers-macos-x86_64.tar.gz
- macOS Apple Silicon: 100-numbers-macos-aarch64.tar.gz"
}

# Create and push the tag
Write-Host "Creating git tag..." -ForegroundColor Yellow
if ($DryRun) {
    Write-Host "[DRY RUN] Would run: git tag -a $Version -m `"$Message`"" -ForegroundColor Gray
    Write-Host "[DRY RUN] Would run: git push origin $Version" -ForegroundColor Gray
} else {
    if ($tagExists -and $Force) {
        git tag -d $Version
        git push origin --delete $Version 2>$null
    }

    git add CHANGELOG.md 2>$null
    git commit -m "Prepare release $Version" 2>$null

    git tag -a $Version -m $Message
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to create git tag" -ForegroundColor Red
        exit 1
    }

    Write-Host "Pushing tag to remote..." -ForegroundColor Yellow
    git push origin $Version
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to push tag to remote" -ForegroundColor Red
        exit 1
    }

    git push origin main 2>$null
}

Write-Host ""
Write-Host "Release $Version created successfully!" -ForegroundColor Green
Write-Host "GitHub Actions will automatically:" -ForegroundColor Cyan
Write-Host "  1. Run tests on all platforms" -ForegroundColor White
Write-Host "  2. Build release binaries" -ForegroundColor White
Write-Host "  3. Create GitHub Release with assets" -ForegroundColor White
Write-Host "  4. Generate release notes" -ForegroundColor White

Write-Host ""
Write-Host "Monitor the release process at:" -ForegroundColor Yellow
Write-Host "https://github.com/aless/100-numbers/actions" -ForegroundColor White

if (-not $DryRun) {
    Write-Host ""
    Write-Host "The release will be available at:" -ForegroundColor Yellow
    Write-Host "https://github.com/aless/100-numbers/releases/tag/$Version" -ForegroundColor White
}
