-- Reviewed Edit-mode invocation wrapper. This wrapper performs no fallback resolution.
local root = assert(workspace:FindFirstChild("CozyWorld_Draft01"), "Workspace.CozyWorld_Draft01 is required")
local mvp = assert(root:FindFirstChild("MVP"), "CozyWorld_Draft01.MVP is required")
local anchorFolder = assert(mvp:FindFirstChild("Anchors"), "CozyWorld_Draft01.MVP.Anchors is required")
local tools = assert(game:GetService("ServerStorage"):FindFirstChild("PhuongMVPTools"), "ServerStorage.PhuongMVPTools is required")
local builders = assert(tools:FindFirstChild("builders"), "ServerStorage.PhuongMVPTools.builders is required")
local anchorNames = { "GameplayBedroomArrival", "Q01Bed", "JasperBedroomStart", "JasperFetchYard", "Q03FairCraft", "Q03BedroomDisplay", "Q04QuadReading", "Q05UDistrictVending", "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving", "FinalePatio", "BirthdayLobbyQueue" }
local anchorMap, missing = require(game:GetService("ServerScriptService").PhuongMVP.shared.Anchors).Resolve(anchorFolder)
assert(#missing == 0, "missing measured anchors: " .. table.concat(missing, ", "))
local anchors = {}
for _, name in ipairs(anchorNames) do
    local anchor = assert(anchorMap[name] or anchorFolder:FindFirstChild(name), "missing measured anchor: " .. anchorFolder:GetFullName() .. "." .. name)
    assert(anchor:IsA("BasePart"), "anchor is not BasePart: " .. anchor:GetFullName())
    local status = anchor:GetAttribute("PlacementStatus")
    assert(type(status) == "string" and status ~= "" and status ~= "UNRESOLVED_LIVE_ANCHOR" and status ~= "UNRESOLVED", "anchor is not measured: " .. anchor:GetFullName())
    anchors[name] = anchor
end
local optionsModule = assert(game:GetService("ServerScriptService").PhuongMVP.shared.MeasuredInstallOptions, "mounted MeasuredInstallOptions is required")
local options = require(optionsModule).FromWorld(root, anchors)
assert(options.OuterQuadBounds and options.Keepouts and options.WorldBounds, "measured install options incomplete")
local installer = require(tools.install)
local result = installer({ Root = root, MVP = mvp, Anchors = anchors, Options = options, Builders = builders, Lighting = game:GetService("Lighting") })
assert(result and result.folders and result.manifest, "installer result missing manifest")
print("Q07 install wrapper complete; anchors=" .. tostring(#anchorNames) .. ", builders=" .. tostring(#builders:GetChildren()))
return result.manifest
