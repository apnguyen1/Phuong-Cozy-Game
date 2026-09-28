param(
    [string]$LuauPath = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$specRoot = Join-Path $repoRoot "roblox/mvp/tests"

if ([string]::IsNullOrWhiteSpace($LuauPath)) {
    $candidate = Get-Command luau -ErrorAction SilentlyContinue
    if ($candidate) { $LuauPath = $candidate.Source }
}

if ([string]::IsNullOrWhiteSpace($LuauPath)) {
    Write-Error "BLOCKED: no local Luau runtime was found. The Luau specs under roblox/mvp/tests were not executed. Run them in the exclusive Studio test window with the MVP modules installed, or provide -LuauPath to a compatible runner."
    exit 2
}

$specs = Get-ChildItem $specRoot -Filter '*.spec.luau' | Sort-Object Name
if ($specs.Count -eq 0) {
    Write-Error "BLOCKED: no Luau spec files found under $specRoot"
    exit 2
}

$failed = @()
foreach ($spec in $specs) {
    Write-Host "RUN $($spec.Name)"
    & $LuauPath $spec.FullName
    if ($LASTEXITCODE -ne 0) { $failed += $spec.Name }
}

if ($failed.Count -gt 0) {
    Write-Error ("FAIL: Luau specs failed: " + ($failed -join ", "))
    exit 1
}

Write-Host ("PASS: executed " + $specs.Count + " Luau specs")
exit 0
