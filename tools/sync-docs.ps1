#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Sync docs from M9A repository to local project
.DESCRIPTION
    This script clones or updates the M9A repository and synchronizes documentation files to the current project.
.EXAMPLE
    .\sync-docs.ps1
#>

# Set error handling
$ErrorActionPreference = "Stop"

# Color output function
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Get project root directory (parent of the scripts folder)
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$TempDir = Join-Path $ProjectRoot "M9A-temp"
$DocsDir = Join-Path $ProjectRoot "docs"

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "M9A Docs Sync Script" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-Host ""

# Check if git is available
try {
    git --version | Out-Null
} catch {
    Write-ColorOutput "Error: git command not found. Please install Git first." "Red"
    exit 1
}

# Clone or update M9A repository
if (Test-Path $TempDir) {
    Write-ColorOutput "Updating M9A repository..." "Yellow"
    Push-Location $TempDir
    try {
        git fetch origin
        git reset --hard origin/main
        Write-ColorOutput "✓ M9A repository updated successfully" "Green"
    } catch {
        Write-ColorOutput "✗ Update failed: $_" "Red"
        Pop-Location
        exit 1
    }
    Pop-Location
} else {
    Write-ColorOutput "Cloning M9A repository..." "Yellow"
    try {
        git clone https://github.com/MAA1999/M9A.git $TempDir
        Write-ColorOutput "✓ M9A repository cloned successfully" "Green"
    } catch {
        Write-ColorOutput "✗ Clone failed: $_" "Red"
        exit 1
    }
}

Write-Host ""
Write-ColorOutput "Start syncing docs..." "Yellow"

# Ensure target directories exist
$TargetDirs = @(
    (Join-Path $DocsDir "zh_cn"),
    (Join-Path $DocsDir "en_us")
)

foreach ($dir in $TargetDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Sync root README.md
$SourceReadme = Join-Path $TempDir "docs\README.md"
$TargetReadme = Join-Path $DocsDir "README.md"

if (Test-Path $SourceReadme) {
    Write-ColorOutput "  → Sync docs/README.md" "White"
    Copy-Item -Path $SourceReadme -Destination $TargetReadme -Force
    Write-ColorOutput "    ✓ Done" "Green"
} else {
    Write-ColorOutput "    ⚠ Source file not found: $SourceReadme" "Yellow"
}

# Sync zh_cn docs
$SourceZhCn = Join-Path $TempDir "docs\zh_cn"
$TargetZhCn = Join-Path $DocsDir "zh_cn"

if (Test-Path $SourceZhCn) {
    Write-ColorOutput "  → Sync docs/zh_cn/" "White"
    
    # Use robocopy for mirroring (Windows built-in)
    # /MIR: mirror directory (delete files not in source)
    # /NFL /NDL /NJH /NJS: reduce output
    # /R:0 /W:0: no retry
    $result = robocopy $SourceZhCn $TargetZhCn /MIR /NFL /NDL /NJH /NJS /R:0 /W:0
    
    if ($LASTEXITCODE -le 7) {
        Write-ColorOutput "    ✓ Done" "Green"
    } else {
        Write-ColorOutput "    ⚠ Warning during sync (exit code: $LASTEXITCODE)" "Yellow"
    }
} else {
    Write-ColorOutput "    ⚠ Source directory not found: $SourceZhCn" "Yellow"
}

# Sync en_us docs
$SourceEnUs = Join-Path $TempDir "docs\en_us"
$TargetEnUs = Join-Path $DocsDir "en_us"

if (Test-Path $SourceEnUs) {
    Write-ColorOutput "  → Sync docs/en_us/" "White"
    
    $result = robocopy $SourceEnUs $TargetEnUs /MIR /NFL /NDL /NJH /NJS /R:0 /W:0
    
    if ($LASTEXITCODE -le 7) {
        Write-ColorOutput "    ✓ Done" "Green"
    } else {
        Write-ColorOutput "    ⚠ Warning during sync (exit code: $LASTEXITCODE)" "Yellow"
    }
} else {
    Write-ColorOutput "    ⚠ Source directory not found: $SourceEnUs" "Yellow"
}

Write-Host ""
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Sync completed!" "Green"
Write-ColorOutput "========================================" "Cyan"
Write-Host ""
Write-ColorOutput "Note: Temporary files are in the M9A-temp directory and can be deleted anytime." "Gray"
