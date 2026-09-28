-- Edit-mode anchor builder. Creates/updates only MVP.Anchors; never destroys MVP or world content.
local root = assert(workspace:FindFirstChild("CozyWorld_Draft01"), "Existing CozyWorld_Draft01 is required")
local mvp = root:FindFirstChild("MVP") or Instance.new("Folder")
mvp.Name = "MVP"; mvp:SetAttribute("Source", "roblox/mvp/build-world.luau"); mvp.Parent = root
local anchors = mvp:FindFirstChild("Anchors") or Instance.new("Folder")
anchors.Name = "Anchors"; anchors.Parent = mvp
local names = {"GameplayBedroomArrival","Q01Bed","JasperBedroomStart","JasperFetchYard","Q03FairCraft","Q03BedroomDisplay","Q04QuadReading","Q04BedroomKindle","Q05UDistrictVending","Q06FOBCounter","Q06AladdinsCounter","Q06Serving","FinalePatio","BirthdayLobbyQueue"}
for _, name in names do
    local marker = anchors:FindFirstChild(name) or Instance.new("Part")
    marker.Name = name; marker.Size = marker.Size.Magnitude > 0 and marker.Size or Vector3.new(1,.15,1)
    marker.Anchored = true; marker.CanCollide = false; marker.CanTouch = false; marker.CanQuery = true; marker.Transparency = 1
    marker:SetAttribute("PlacementStatus", marker:GetAttribute("PlacementStatus") or "UNRESOLVED_LIVE_ANCHOR"); marker.Parent = anchors
end
print("MVP anchor subtree updated; unresolved anchors remain rejected by resolver")
