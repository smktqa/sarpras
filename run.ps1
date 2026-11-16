<#
    run.ps1 - Jalankan Sistem SARPRAS di lokal (Windows)

    Pemakaian:
        .\run.ps1                  -> http://127.0.0.1:8000
        .\run.ps1 -Port 8001       -> ganti port
        .\run.ps1 -Rebuild         -> buang venv lama, buat ulang dari nol
#>
[CmdletBinding()]
param(
    [int]$Port = 8000,
    [switch]$Rebuild
)

# Catatan: sengaja "Continue", bukan "Stop". Di PowerShell 5.1 output stderr dari
# program native (pip, python) diperlakukan sebagai error dan akan menghentikan
# script kalau ErrorActionPreference = "Stop".
$ErrorActionPreference = "Continue"
Set-Location -Path $PSScriptRoot

$VenvDir = Join-Path $PSScriptRoot "venv"
$VenvPy  = Join-Path $VenvDir "Scripts\python.exe"
$VenvCfg = Join-Path $VenvDir "pyvenv.cfg"
$ReqFile = Join-Path $PSScriptRoot "requirements.txt"
$DbFile  = Join-Path $PSScriptRoot "db.sqlite3"

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }

function Test-VenvHealthy {
    if (-not (Test-Path $VenvPy)) { return $false }
    if (-not (Test-Path $VenvCfg)) { return $false }

    # venv hasil pindahan mesin lain punya "home" yang tidak ada di komputer ini
    $homeLine = Select-String -Path $VenvCfg -Pattern '^home\s*=\s*(.+)$' | Select-Object -First 1
    if (-not $homeLine) { return $false }
    if (-not (Test-Path $homeLine.Matches[0].Groups[1].Value.Trim())) { return $false }

    return (Test-Path (Join-Path $VenvDir "Lib\site-packages\django\__init__.py"))
}

function Move-VenvAside($label) {
    $target = Join-Path $PSScriptRoot ("{0}_{1}" -f $label, (Get-Date -Format "yyyyMMdd_HHmmss"))
    Write-Step "Memindahkan venv lama ke $(Split-Path $target -Leaf)"
    Move-Item -Path $VenvDir -Destination $target -ErrorAction Stop
}

if ($Rebuild -and (Test-Path $VenvDir)) { Move-VenvAside "venv_lama" }

if (-not (Test-VenvHealthy)) {
    if (Test-Path $VenvDir) { Move-VenvAside "venv_rusak" }

    Write-Step "Membuat virtual environment (Python 3.14)"
    if (Get-Command py -ErrorAction SilentlyContinue) {
        & py -3.14 -m venv $VenvDir
    } elseif (Get-Command python -ErrorAction SilentlyContinue) {
        & python -m venv $VenvDir
    } else {
        throw "Python tidak ditemukan. Install Python 3.12+ lalu jalankan ulang."
    }
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $VenvPy)) {
        throw "Gagal membuat virtual environment di $VenvDir"
    }
}

Write-Step "Memeriksa dependency"
& $VenvPy -m pip install --disable-pip-version-check -q --upgrade pip
& $VenvPy -m pip install --disable-pip-version-check -q -r $ReqFile
if ($LASTEXITCODE -ne 0) {
    throw "Dependency gagal terpasang. Jalankan manual: .\venv\Scripts\python.exe -m pip install -r requirements.txt"
}

if (-not (Test-Path $DbFile)) {
    Write-Step "Database belum ada, menjalankan migrate"
    & $VenvPy manage.py migrate
}

$occupied = $null
try {
    $occupied = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
} catch { }
if ($occupied) {
    throw "Port $Port sudah dipakai. Coba: .\run.ps1 -Port $($Port + 1)"
}

Write-Step "Server aktif di http://127.0.0.1:$Port/"
Write-Host "    Admin : http://127.0.0.1:$Port/admin/   (user: admin)" -ForegroundColor DarkGray
Write-Host "    Stop  : Ctrl+C" -ForegroundColor DarkGray

& $VenvPy manage.py runserver "127.0.0.1:$Port"
