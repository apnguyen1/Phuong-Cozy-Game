param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'bundle-out')
)

$sourceRoot = Join-Path $RepoRoot 'roblox\mvp'
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$entries = @(
    @{ Relative='shared\Anchors.luau'; Target='ReplicatedStorage/PhuongMVP/shared/Anchors'; Kind='ModuleScript' },
    @{ Relative='shared\Config.luau'; Target='ReplicatedStorage/PhuongMVP/shared/Config'; Kind='ModuleScript' },
    @{ Relative='shared\Anchors.luau'; Target='ServerScriptService/PhuongMVP/shared/Anchors'; Kind='ModuleScript' },
    @{ Relative='shared\Config.luau'; Target='ServerScriptService/PhuongMVP/shared/Config'; Kind='ModuleScript' },
    @{ Relative='shared\MeasuredInstallOptions.luau'; Target='ServerScriptService/PhuongMVP/shared/MeasuredInstallOptions'; Kind='ModuleScript' },
    @{ Relative='server\SessionService.luau'; Target='ServerScriptService/PhuongMVP/server/SessionService'; Kind='ModuleScript' },
    @{ Relative='server\CakeService.luau'; Target='ServerScriptService/PhuongMVP/server/CakeService'; Kind='ModuleScript' },
    @{ Relative='server\QueueService.luau'; Target='ServerScriptService/PhuongMVP/server/QueueService'; Kind='ModuleScript' },
    @{ Relative='server\TeleportAdapter.luau'; Target='ServerScriptService/PhuongMVP/server/TeleportAdapter'; Kind='ModuleScript' },
    @{ Relative='server\LocalPartyTransferAdapter.luau'; Target='ServerScriptService/PhuongMVP/server/LocalPartyTransferAdapter'; Kind='ModuleScript' },
    @{ Relative='server\activities\Q01.luau'; Target='ServerScriptService/PhuongMVP/server/activities/Q01'; Kind='ModuleScript' },
    @{ Relative='server\activities\Q02.luau'; Target='ServerScriptService/PhuongMVP/server/activities/Q02'; Kind='ModuleScript' },
    @{ Relative='server\activities\Q03.luau'; Target='ServerScriptService/PhuongMVP/server/activities/Q03'; Kind='ModuleScript' },
    @{ Relative='server\activities\Q04.luau'; Target='ServerScriptService/PhuongMVP/server/activities/Q04'; Kind='ModuleScript' },
    @{ Relative='server\activities\Q05.luau'; Target='ServerScriptService/PhuongMVP/server/activities/Q05'; Kind='ModuleScript' },
    @{ Relative='server\activities\Q06.luau'; Target='ServerScriptService/PhuongMVP/server/activities/Q06'; Kind='ModuleScript' },
    @{ Relative='server\Main.server.luau'; Target='ServerScriptService/PhuongMVP/server/Main'; Kind='Script' },
    @{ Relative='client\Main.client.luau'; Target='StarterPlayer/StarterPlayerScripts/PhuongMVPClient'; Kind='LocalScript' },
    @{ Relative='install.luau'; Target='ServerStorage/PhuongMVPTools/install'; Kind='ModuleScript' },
    @{ Relative='build-world.luau'; Target='ServerStorage/PhuongMVPTools/build-world'; Kind='Script' },
    @{ Relative='builders\Q01Station.luau'; Target='ServerStorage/PhuongMVPTools/builders/Q01Station'; Kind='ModuleScript' },
    @{ Relative='builders\Q02Station.luau'; Target='ServerStorage/PhuongMVPTools/builders/Q02Station'; Kind='ModuleScript' },
    @{ Relative='builders\Q03Station.luau'; Target='ServerStorage/PhuongMVPTools/builders/Q03Station'; Kind='ModuleScript' },
    @{ Relative='builders\Q04Station.luau'; Target='ServerStorage/PhuongMVPTools/builders/Q04Station'; Kind='ModuleScript' },
    @{ Relative='builders\Q05Station.luau'; Target='ServerStorage/PhuongMVPTools/builders/Q05Station'; Kind='ModuleScript' },
    @{ Relative='builders\Q06Station.luau'; Target='ServerStorage/PhuongMVPTools/builders/Q06Station'; Kind='ModuleScript' },
    @{ Relative='builders\CakeFinale.luau'; Target='ServerStorage/PhuongMVPTools/builders/CakeFinale'; Kind='ModuleScript' },
    @{ Relative='builders\LobbyQueue.luau'; Target='ServerStorage/PhuongMVPTools/builders/LobbyQueue'; Kind='ModuleScript' },
    @{ Relative='builders\SeattleBoundary.luau'; Target='ServerStorage/PhuongMVPTools/builders/SeattleBoundary'; Kind='ModuleScript' },
    @{ Relative='builders\NightLighting.luau'; Target='ServerStorage/PhuongMVPTools/builders/NightLighting'; Kind='ModuleScript' },
    @{ Relative='builders\GrassDecoration.luau'; Target='ServerStorage/PhuongMVPTools/builders/GrassDecoration'; Kind='ModuleScript' }
)
$hashes = foreach ($entry in $entries) {
    $path = Join-Path $sourceRoot $entry.Relative
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing source: $path" }
    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    [pscustomobject]@{ relative=$entry.Relative; target=$entry.Target; kind=$entry.Kind; sha256=$hash }
}
$hashes | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $OutputDirectory 'source-hashes.json') -Encoding UTF8

function XmlEscape([string]$value) { return [System.Security.SecurityElement]::Escape($value) }
$xml = [System.Text.StringBuilder]::new()
[void]$xml.AppendLine('<roblox version="4">')
$entryIndex = 0
foreach ($entry in $entries) {
    $entryIndex++
    $path = Join-Path $sourceRoot $entry.Relative
    $source = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $name = Split-Path $entry.Target -Leaf
    $class = $entry.Kind
    $referent = "RBXMVP$('{0:D3}' -f $entryIndex)"
    [void]$xml.AppendLine(('  <Item class="{0}" referent="{1}">' -f $class, $referent))
    [void]$xml.AppendLine(('    <Properties><string name="Name">{0}</string><ProtectedString name="Source"><![CDATA[{1}]]></ProtectedString></Properties>' -f (XmlEscape $name), $source))
    [void]$xml.AppendLine('  </Item>')
}
[void]$xml.AppendLine('</roblox>')
$xml.ToString() | Set-Content -LiteralPath (Join-Path $OutputDirectory 'Phuong-Cozy-MVP-source.rbxmx') -Encoding UTF8
Write-Output "Wrote bundle-out\Phuong-Cozy-MVP-source.rbxmx and source-hashes.json"
