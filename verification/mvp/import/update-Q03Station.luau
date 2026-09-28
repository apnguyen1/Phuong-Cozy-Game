local HttpService=game:GetService("HttpService")
local parent=assert(game:GetService("ServerStorage").PhuongMVPTools.builders)
local old=assert(parent:FindFirstChild("Q03Station"));assert(old:IsA("ModuleScript") and old:GetAttribute("PhuongMVPImportOwned"),"owned module required")
local expectedSource=HttpService:JSONDecode(HttpService:JSONEncode([=[return function(context)
    assert(context and context.Root and context.MVP and context.MVP.Stations, "Q03Station context is incomplete")
    assert(type(context.SafeReplace) == "function", "Q03Station requires SafeReplace")
    local anchors = assert(context.Anchors, "Q03Station Anchors required")
    local boothAnchor = assert(anchors.Q03FairCraft, "Q03FairCraft anchor required")
    local homeAnchor = assert(anchors.Q03BedroomDisplay, "Q03BedroomDisplay anchor required")
    assert(boothAnchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q03FairCraft anchor unresolved")
    assert(homeAnchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q03BedroomDisplay anchor unresolved")
    local palette = assert(context.Palette, "Q03Station palette required")
    for _, token in ipairs({"forest", "sage", "cream", "wood", "blossom", "golden", "ink"}) do assert(palette[token], "missing palette token: " .. token) end
    local manifest = {AnchorName="Q03FairCraft;Q03BedroomDisplay", Footprint="14x10 proposed; measured anchors required", ApproachClearance="3 front; 2 side proposed", Owner="Task04", SourceBuilder="roblox/mvp/builders/Q03Station.luau"}
    local function factory()
        local folder = Instance.new("Folder"); folder.Name = "Q03"; folder:SetAttribute("VerificationTicket", "PCW-09"); folder:SetAttribute("MVPBuilder", "Q03Station"); folder:SetAttribute("Owner", "Task04")
        local function part(name,size,cf,token,parent,collide)
            local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=palette[token]; p.Anchored=true; p.CanCollide=collide==true
            for key,value in pairs({VerificationTicket="PCW-09",PaletteToken=token,MVPBuilder="Q03Station",AnchorName=manifest.AnchorName,Footprint=manifest.Footprint,ApproachClearance=manifest.ApproachClearance,Owner=manifest.Owner,SourceBuilder=manifest.SourceBuilder}) do p:SetAttribute(key,value) end
            p.Parent=parent; return p
        end
        local function piece(name,size,cf,token) local m=Instance.new("Model"); m.Name=name; m.Parent=folder; part("Body",size,cf,token,m,false); return m end
        local b,h=boothAnchor.CFrame,homeAnchor.CFrame
        part("CraftTable",Vector3.new(8,2,4),b*CFrame.new(0,1,0),"wood",folder,true)
        for i=1,6 do local x=((i-1)%3-1)*2.2; local z=(math.floor((i-1)/3)-.5)*1.5; part("Socket_"..i,Vector3.new(1.4,.08,1.1),b*CFrame.new(x,2.05,z),"golden",folder,false) end
        piece("Rug",Vector3.new(2.4,.08,1.8),b*CFrame.new(-2.2,2.12,-.75),"sage"); piece("Chair",Vector3.new(1.2,1.4,1.2),b*CFrame.new(0,2.8,-.75),"sage"); piece("Bookcase",Vector3.new(1.1,1.8,.45),b*CFrame.new(2.2,2.9,-.75),"wood"); piece("SideTable",Vector3.new(1,.8,1),b*CFrame.new(-2.2,2.55,.75),"wood"); piece("Plant",Vector3.new(.7,1.2,.7),b*CFrame.new(0,2.7,.75),"forest"); piece("Lamp",Vector3.new(.6,1.4,.6),b*CFrame.new(2.2,2.8,.75),"golden")
        local home=Instance.new("Model"); home.Name="HomeDisplay"; home.Parent=folder; part("DisplayBase",Vector3.new(7,.3,5),h*CFrame.new(0,.2,0),"wood",home,false); home:SetAttribute("SharedState","Q03 server miniature; booth and desk are one state"); home:SetAttribute("NoDuplicateReward",true)
        return folder
    end
    local installed=context.SafeReplace("Q03Station",factory)
    return {folder=installed,manifest=manifest}
end
]=]));local n=Instance.new("ModuleScript");n.Name="Q03Station";n:SetAttribute("PhuongMVPImportOwned",true);n:SetAttribute("PhuongMVPSourceSHA256","731FBE638669BCF4316C40090931A74F43B499FCACAD2D8D8DFBEAE56E4D58C9");n.Source=expectedSource;assert(n.Source==expectedSource,"source readback mismatch");n.Parent=parent;old:Destroy();return true
