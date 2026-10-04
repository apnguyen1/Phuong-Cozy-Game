-- Edit-mode repair: extend city facades downward, preserving their roof height.
local root=workspace.CozyWorld_Draft01
local field=root.Landscape:WaitForChild("QuadGround")
local groundY=field.Position.Y+field.Size.Y/2
local boundary=root.MVP.Environment:WaitForChild("SeattleBoundary")
local count=0
for _,p in boundary:GetDescendants() do
 if p:IsA("BasePart") and (p.Name:match("^Shell%d+$") or (p.Name=="Body" and p.Parent.Parent.Name=="CompressedSeattleSkyline")) then
  local top=p.Position.Y+p.Size.Y/2
  if p.Position.Y-p.Size.Y/2>groundY then
   local height=top-groundY
   p.Size=Vector3.new(p.Size.X,height,p.Size.Z)
   p.CFrame=p.CFrame+Vector3.new(0,groundY+height/2-p.Position.Y,0)
   count+=1
  end
 end
end
boundary:SetAttribute("GroundedFieldY",groundY)
return {extended=count,fieldY=groundY}
