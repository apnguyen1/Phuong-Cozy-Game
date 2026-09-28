-- Edit-mode builder. Requiring this module has no live-world side effects.
-- Canonical integration shape: return function(context).
local COLORS={golden=Color3.fromRGB(232,199,121),cream=Color3.fromRGB(245,240,228),forest=Color3.fromRGB(54,87,68),ink=Color3.fromRGB(38,56,46)}
local DEFINITIONS={
 Bedroom={anchor="GameplayBedroomArrival",offset=CFrame.new(0,7,0),range=24,brightness=1.35,shadows=true}, BedroomBedside={anchor="Q01Bed",offset=CFrame.new(2,3,1),range=14,brightness=.8,shadows=false}, Lobby={anchor="BirthdayLobbyQueue",offset=CFrame.new(0,6,0),range=20,brightness=1.1,shadows=true}, Craft={anchor="Q03FairCraft",offset=CFrame.new(0,5,0),range=18,brightness=1,shadows=false}, Vending={anchor="Q05UDistrictVending",offset=CFrame.new(0,5,0),range=16,brightness=1,shadows=false}, Food={anchor="Q06Serving",offset=CFrame.new(0,5,0),range=20,brightness=1.1,shadows=true}, Quad={anchor="Q04QuadReading",offset=CFrame.new(0,7,0),range=22,brightness=.8,shadows=false}, Patio={anchor="FinalePatio",offset=CFrame.new(0,6,0),range=22,brightness=1.1,shadows=true}, RouteBedroom={anchor="GameplayBedroomArrival",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false}, RouteDistrict={anchor="Q03FairCraft",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false}, RouteQuad={anchor="Q04QuadReading",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false}, RoutePatio={anchor="FinalePatio",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false},
}
local REQUIRED={"GameplayBedroomArrival","Q01Bed","BirthdayLobbyQueue","Q03FairCraft","Q05UDistrictVending","Q06Serving","Q04QuadReading","FinalePatio"}
local GLOBAL_KEYS={"ClockTime","Brightness","ExposureCompensation","GlobalShadows","Ambient","OutdoorAmbient","EnvironmentDiffuseScale","EnvironmentSpecularScale","ShadowSoftness"}
local function findAnchor(context,name) return context.Anchors[name] or context.Root:FindFirstChild(name,true) end
local function preflight(context)
 assert(context and context.Root and context.MVP and context.Anchors and context.Palette,"NightLighting context is required")
 for _,name in REQUIRED do local anchor=findAnchor(context,name); assert(anchor and anchor:IsA("BasePart"),"NightLighting missing required anchor: "..name); assert(anchor:GetAttribute("PlacementStatus")~="UNRESOLVED_LIVE_ANCHOR","NightLighting unresolved anchor: "..name) end
 for _,token in {"forest","sage","cream","wood","blossom","brick","golden","ink"} do assert(context.Palette[token],"NightLighting missing palette token: "..token) end
end
local function captureLighting(lighting) local result={}; for _,key in GLOBAL_KEYS do result[key]=lighting[key] end; return result end
local function restoreLighting(lighting,values) for key,value in values do lighting[key]=value end end
local function buildDetached(context,options)
 local folder=Instance.new("Folder"); folder.Name="NightLighting"; folder:SetAttribute("Owner","Task11"); folder:SetAttribute("MVPBuilder","NightLighting"); folder:SetAttribute("Source","roblox/mvp/builders/NightLighting.luau"); folder:SetAttribute("Status","Implementation delivered; Studio/device verification pending"); folder:SetAttribute("HighShadowBudget",12); folder:SetAttribute("LowShadowBudget",6)
 local created,shadowCount={},0
 for name,definition in DEFINITIONS do
  local anchor=findAnchor(context,definition.anchor); assert(anchor and anchor:IsA("BasePart"),"NightLighting anchor changed during build: "..definition.anchor)
  local part=Instance.new("Part"); part.Name=name; part.Size=Vector3.new(.25,.25,.25); part.Transparency=1; part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false; part.CFrame=anchor.CFrame*definition.offset; part:SetAttribute("VerificationTicket","PCW-01"); part:SetAttribute("PaletteToken","golden"); part:SetAttribute("MVPBuilder","NightLighting"); part:SetAttribute("AnchorName",definition.anchor); part:SetAttribute("Footprint","0.25x0.25x0.25 invisible fixture"); part:SetAttribute("ApproachClearance","No collision; does not alter route"); part:SetAttribute("Owner","Task11"); part:SetAttribute("SourceBuilder","roblox/mvp/builders/NightLighting.luau"); part.Parent=folder
  local light=Instance.new("PointLight"); light.Name="WarmFixture"; light.Color=COLORS.golden; light.Brightness=options.lowGraphics and math.min(definition.brightness,1) or definition.brightness; light.Range=definition.range; light.Shadows=options.lowGraphics and false or definition.shadows; light.Parent=part
  table.insert(created,name); if light.Shadows then shadowCount+=1 end
 end
 folder:SetAttribute("CreatedFixtureCount",#created); folder:SetAttribute("ShadowFixtureCount",shadowCount); return folder,created,shadowCount
end
local function applyGlobals(lighting)
 lighting.ClockTime=22; lighting.Brightness=2; lighting.ExposureCompensation=.1; lighting.GlobalShadows=true; lighting.Ambient=COLORS.forest; lighting.OutdoorAmbient=COLORS.ink; lighting.EnvironmentDiffuseScale=.45; lighting.EnvironmentSpecularScale=.15; lighting.ShadowSoftness=.85
 local atmosphere=lighting:FindFirstChild("MVPNightAtmosphere"); local created=false; if not atmosphere then atmosphere=Instance.new("Atmosphere"); atmosphere.Name="MVPNightAtmosphere"; atmosphere.Parent=lighting; created=true end
 local original={Density=atmosphere.Density,Haze=atmosphere.Haze,Glare=atmosphere.Glare,Color=atmosphere.Color,Decay=atmosphere.Decay}; atmosphere.Density=.07; atmosphere.Haze=.08; atmosphere.Glare=0; atmosphere.Color=COLORS.cream; atmosphere.Decay=COLORS.forest
 return atmosphere,created,original
end
return function(context)
 preflight(context)
 local lighting=context.Lighting or game:GetService("Lighting"); local options=context.Options or {}; local folder,created,shadowCount=buildDetached(context,options); local originalLighting=captureLighting(lighting); local atmosphere,atmosphereCreated,originalAtmosphere=applyGlobals(lighting)
 local restored=false
 local function restoreOwned() if restored then return end; restored=true; restoreLighting(lighting,originalLighting); if atmosphere and atmosphere.Parent then if atmosphereCreated then atmosphere:Destroy() else for key,value in originalAtmosphere do atmosphere[key]=value end end end end
 local ok,installed=pcall(function() return context.SafeReplace("NightLighting",function() return folder end) end)
 if not ok then restoreOwned(); error(installed) end
 return {folder=installed,manifest={Owner="Task11",SourceBuilder="roblox/mvp/builders/NightLighting.luau",VerificationTicket="PCW-01",RequiredAnchors=REQUIRED,Created=created,ShadowCount=shadowCount,HighShadowBudget=12,LowShadowBudget=6,GlobalLightingProperties=GLOBAL_KEYS},Restore=restoreOwned}
end
