-- Repeatable Edit-mode afternoon lighting and six extra Quad lamps.
local lighting=game:GetService("Lighting")
lighting.ClockTime=15.5; lighting.Brightness=1.6; lighting.ExposureCompensation=-.15
lighting.GlobalShadows=true; lighting.Ambient=Color3.fromRGB(168,185,149); lighting.OutdoorAmbient=Color3.fromRGB(168,185,149)
lighting.EnvironmentDiffuseScale=.65; lighting.EnvironmentSpecularScale=.15; lighting.ShadowSoftness=.85
local root=workspace.CozyWorld_Draft01
local quad=root.QuadPlanting
local old=quad:FindFirstChild("AfternoonLamps")
if old then old:Destroy() end
local folder=Instance.new("Folder"); folder.Name="AfternoonLamps"; folder:SetAttribute("VerificationTicket","MAP-03"); folder.Parent=quad
local reference=quad:WaitForChild("PathLantern1"):GetPivot().Position
local colors={ink=Color3.fromRGB(38,56,46),golden=Color3.fromRGB(232,199,121)}
local function part(model,name,size,position,token)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=position; p.Anchored=true
 p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Color=colors[token]; p.Material=Enum.Material.SmoothPlastic
 p:SetAttribute("PaletteToken",token); p:SetAttribute("VerificationTicket","MAP-03"); p.Parent=model; return p
end
for i,offset in ipairs({Vector3.new(0,0,50),Vector3.new(0,0,100),Vector3.new(0,0,145),Vector3.new(177,0,25),Vector3.new(177,0,65),Vector3.new(177,0,155)}) do
 local model=Instance.new("Model"); model.Name=string.format("QuadLamp%02d",i); model.Parent=folder
 local base=reference+offset+Vector3.new(0,.06,0)
 local ray=RaycastParams.new(); ray.FilterType=Enum.RaycastFilterType.Include; ray.FilterDescendantsInstances={root.Landscape,root.Paths}
 local hit=workspace:Raycast(base+Vector3.new(0,20,0),Vector3.new(0,-40,0),ray)
 if hit then base=Vector3.new(base.X,hit.Position.Y,base.Z) end
 part(model,"Foot",Vector3.new(1.2,.25,1.2),base+Vector3.new(0,.125,0),"ink")
 part(model,"Post",Vector3.new(.3,10,.3),base+Vector3.new(0,5,0),"ink")
 part(model,"LanternBase",Vector3.new(1.2,.2,1.2),base+Vector3.new(0,10,0),"ink")
 local glow=part(model,"WarmGlass",Vector3.new(.85,1.2,.85),base+Vector3.new(0,10.7,0),"golden")
 part(model,"LanternCap",Vector3.new(1.4,.25,1.4),base+Vector3.new(0,11.45,0),"ink")
 local light=Instance.new("PointLight"); light.Name="WarmLampLight"; light.Color=colors.golden; light.Brightness=.45; light.Range=14; light.Shadows=false; light.Parent=glow
end
return {clock=lighting.ClockTime,extraLamps=#folder:GetChildren()}
