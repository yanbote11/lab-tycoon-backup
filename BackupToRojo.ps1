# ============================================================
# BackupToRojo.ps1 — Virus RNG Simulator / Lab Tycoon
# Run this whenever you want to snapshot your Studio scripts.
# Usage: Right-click → Run with PowerShell  (or: .\BackupToRojo.ps1)
# ============================================================

$ErrorActionPreference = "Stop"

# ── CONFIG ──────────────────────────────────────────────────
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcRoot     = Join-Path $ProjectRoot "src"
$RbxlPath    = Join-Path $ProjectRoot "LabTycoon.rbxl"   # update if name differs
# ────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Lab Tycoon — Rojo Backup Script            ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── STEP 1: Verify rojo is installed ────────────────────────
Write-Host "[1/4] Checking Rojo..." -ForegroundColor Yellow
try {
    $rojoVersion = rojo --version 2>&1
    Write-Host "      Rojo OK: $rojoVersion" -ForegroundColor Green
} catch {
    Write-Host "      ERROR: Rojo not found. Install from https://rojo.space" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# ── STEP 2: Extract scripts from .rbxl using rojo sourcemap ─
Write-Host ""
Write-Host "[2/4] Generating Rojo sourcemap..." -ForegroundColor Yellow

$SourcemapPath = Join-Path $ProjectRoot "sourcemap.json"
try {
    rojo sourcemap "$ProjectRoot\default.project.json" --output $SourcemapPath 2>&1 | Out-Null
    Write-Host "      Sourcemap written to sourcemap.json" -ForegroundColor Green
} catch {
    Write-Host "      Sourcemap generation skipped (OK for snapshot-only workflow)." -ForegroundColor DarkGray
}

# ── STEP 3: Run rojo-fmt / just confirm src files exist ─────
Write-Host ""
Write-Host "[3/4] Scanning src/ snapshot folders..." -ForegroundColor Yellow

$scriptFolders = @(
    "ServerScriptService",
    "StarterPlayer\StarterPlayerScripts",
    "ReplicatedStorage"
)

$totalFiles = 0
foreach ($folder in $scriptFolders) {
    $fullPath = Join-Path $SrcRoot $folder
    if (Test-Path $fullPath) {
        $files = Get-ChildItem -Path $fullPath -Recurse -Filter "*.luau" -ErrorAction SilentlyContinue
        $count = ($files | Measure-Object).Count
        $totalFiles += $count
        Write-Host "      $folder → $count .luau file(s)" -ForegroundColor White
    } else {
        Write-Host "      $folder → (folder not found, skipping)" -ForegroundColor DarkGray
    }
}

Write-Host "      Total tracked files: $totalFiles" -ForegroundColor Green

# ── STEP 4: Git commit ──────────────────────────────────────
Write-Host ""
Write-Host "[4/4] Committing to Git..." -ForegroundColor Yellow

Set-Location $ProjectRoot

# Make sure git is available
try {
    git --version | Out-Null
} catch {
    Write-Host "      ERROR: git not found. Install from https://git-scm.com" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Stage everything
git add -A 2>&1 | Out-Null

# Check if there's anything to commit
$status = git status --porcelain 2>&1
if (-not $status) {
    Write-Host "      Nothing changed since last backup — no commit needed." -ForegroundColor DarkGray
} else {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $commitMsg = "backup: snapshot $timestamp"
    git commit -m $commitMsg 2>&1 | Out-Null
    $hash = git rev-parse --short HEAD 2>&1
    Write-Host "      Committed: $commitMsg ($hash)" -ForegroundColor Green
}

# ── DONE ────────────────────────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Backup complete!                           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tip: To restore a file, run:" -ForegroundColor DarkGray
Write-Host "  git log --oneline" -ForegroundColor DarkGray
Write-Host "  git checkout <commit> -- src/path/to/file.luau" -ForegroundColor DarkGray
Write-Host ""
Read-Host "Press Enter to close"
