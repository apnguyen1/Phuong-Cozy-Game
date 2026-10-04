-- Controlled one-feature Edit-mode invocation. Caller must provide one canonical name.
return function(featureName)
    assert(type(featureName) == "string" and featureName ~= "", "featureName required")
    local allowed = {Q01Station=true,Q02Station=true,Q03Station=true,Q04Station=true,Q05Station=true,Q06Station=true,CakeFinale=true,LobbyQueue=true,SeattleBoundary=true,NightLighting=true,GrassDecoration=true}
    assert(allowed[featureName], "unknown canonical feature")
    local root = assert(workspace:FindFirstChild("CozyWorld_Draft01"), "CozyWorld_Draft01 required")
    local mvp = assert(root:FindFirstChild("MVP"), "MVP required")
    local installer = require(game:GetService("ServerStorage").PhuongMVPTools.install)
    local anchors = assert(mvp:FindFirstChild("Anchors"), "MVP.Anchors required")
    local map, missing = require(game:GetService("ServerScriptService").PhuongMVP.shared.Anchors).Resolve(anchors)
    assert(#missing == 0, "missing anchors: " .. table.concat(missing, ", "))
    local options = require(game:GetService("ServerScriptService").PhuongMVP.shared.MeasuredInstallOptions).FromWorld(root, map)
    local result = installer({Root=root, MVP=mvp, Anchors=map, Options=options, Builders=game:GetService("ServerStorage").PhuongMVPTools.builders, OnlyFeature=featureName, Lighting=game:GetService("Lighting")})
    local count=0;for _ in pairs(result.folders) do count+=1 end;assert(count==1,"expected exactly one installed feature")
    return result
end
