<#
  Builds Tic Tac Toe for appversegames.com and zips it for upload.

  Usage (from the project folder, in PowerShell):
    .\tool\build_web.ps1

  Output: build\tictactoe-web.zip  ->  extract into public_html/play/tictactoe/ on the server.
  Run it from PowerShell, not Git Bash: Git Bash rewrites "/play/..." into a Windows path.
#>
$ErrorActionPreference = "Stop"
$folder = "tictactoe"
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root "build"

Push-Location $root
try {
    # flutter build leaves unknown files in build\web, and they'd end up in the zip.
    if (Test-Path "build\web") { Remove-Item -Recurse -Force "build\web" }
    flutter build web --release --base-href "/play/$folder/" --no-web-resources-cdn
    if ($LASTEXITCODE -ne 0) { throw "flutter build web failed" }
} finally {
    Pop-Location
}

$zip = Join-Path $out "$folder-web.zip"
if (Test-Path $zip) { Remove-Item $zip }
# Not Compress-Archive: on Windows PowerShell 5.1 it writes "\" into entry
# names, which Linux servers can extract as flat files like "assets\foo.wav".
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$webDir = (Resolve-Path (Join-Path $root "build\web")).Path
$archive = [System.IO.Compression.ZipFile]::Open($zip, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    Get-ChildItem $webDir -Recurse -File -Force | ForEach-Object {
        $entry = $_.FullName.Substring($webDir.Length + 1).Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $archive, $_.FullName, $entry, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
} finally {
    $archive.Dispose()
}
Write-Host ""
Write-Host "Built $zip"
Write-Host "Upload: extract its contents into public_html/play/$folder/ on the server."
