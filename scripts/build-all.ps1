# 100 Numbers Game Solver - Local Cross-Platform Build Script
# This script builds the solver for all supported platforms locally

param(
    [string]$BuildType = "ReleaseFast",
    [switch]$Test = $false,
    [switch]$Clean = $false
)

Write-Host "100 Numbers Game Solver - Cross-Platform Builder" -ForegroundColor Cyan
Write-Host "Build Type: $BuildType" -ForegroundColor Yellow

# Clean previous builds if requested
if ($Clean) {
    Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
    if (Test-Path "zig-out") {
        Remove-Item -Recurse -Force "zig-out"
    }
    if (Test-Path "builds") {
        Remove-Item -Recurse -Force "builds"
    }
}

# Run tests if requested
if ($Test) {
    Write-Host "Running comprehensive test suite..." -ForegroundColor Yellow
    zig build test
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Tests failed! Aborting build." -ForegroundColor Red
        exit 1
    }
    Write-Host "All tests passed!" -ForegroundColor Green
}

# Create builds directory
New-Item -ItemType Directory -Path "builds" -Force | Out-Null

# Define target platforms
$targets = @(
    @{ Name = "windows-x86_64"; Target = "x86_64-windows"; Extension = ".exe" },
    @{ Name = "linux-x86_64"; Target = "x86_64-linux"; Extension = "" },
    @{ Name = "linux-aarch64"; Target = "aarch64-linux"; Extension = "" },
    @{ Name = "macos-x86_64"; Target = "x86_64-macos"; Extension = "" },
    @{ Name = "macos-aarch64"; Target = "aarch64-macos"; Extension = "" }
)

Write-Host "Building for $($targets.Count) platforms..." -ForegroundColor Yellow

$successCount = 0
$failedBuilds = @()

foreach ($target in $targets) {
    Write-Host "  Building for $($target.Name)..." -ForegroundColor Gray
    
    # Build for the target platform
    $buildCmd = "zig build -Doptimize=$BuildType -Dtarget=$($target.Target)"
    Invoke-Expression $buildCmd
    
    if ($LASTEXITCODE -eq 0) {
        # Copy the built executable to builds directory
        $sourceFile = if ($target.Extension -eq ".exe") { "zig-out\bin\100.exe" } else { "zig-out\bin\100" }
        $destFile = "builds\100-numbers-$($target.Name)$($target.Extension)"
        
        if (Test-Path $sourceFile) {
            Copy-Item $sourceFile $destFile
            $fileSize = (Get-Item $destFile).Length
            $fileSizeKB = [math]::Round($fileSize / 1KB, 1)
            Write-Host "    Success! ($fileSizeKB KB)" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "    Build succeeded but executable not found" -ForegroundColor Red
            $failedBuilds += $target.Name
        }
    } else {
        Write-Host "    Build failed" -ForegroundColor Red
        $failedBuilds += $target.Name
    }
}

Write-Host ""
Write-Host "Build Summary:" -ForegroundColor Cyan
Write-Host "  Successful: $successCount/$($targets.Count)" -ForegroundColor Green

if ($failedBuilds.Count -gt 0) {
    Write-Host "  Failed: $($failedBuilds.Count)" -ForegroundColor Red
    Write-Host "    Failed targets: $($failedBuilds -join ', ')" -ForegroundColor Red
}

if ($successCount -eq $targets.Count) {
    Write-Host ""
    Write-Host "All builds completed successfully!" -ForegroundColor Green
    Write-Host "Binaries available in 'builds' directory:" -ForegroundColor Yellow
    
    Get-ChildItem "builds" | ForEach-Object {
        $sizeKB = [math]::Round($_.Length / 1KB, 1)
        Write-Host "  $($_.Name) ($sizeKB KB)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "Ready for distribution!" -ForegroundColor Green
} else {
    exit 1
}

Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor Cyan
Write-Host "  .\builds\100-numbers-windows-x86_64.exe    # Windows" -ForegroundColor White
Write-Host "  ./builds/100-numbers-linux-x86_64          # Linux" -ForegroundColor White
Write-Host "  ./builds/100-numbers-macos-x86_64          # macOS" -ForegroundColor White
