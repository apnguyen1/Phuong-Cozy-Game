-- Read-only inspection of authored game UI, used alongside real screenshots
-- and mouse/touch input. Never installs or invokes actions directly.
local player=game:GetService("Players").LocalPlayer
assert(player,"Requires Client datamodel")
local pg=assert(player:FindFirstChildOfClass("PlayerGui"),"PlayerGui unavailable")
local camera=workspace.CurrentCamera
local output={location=player:GetAttribute("BirthdayLocation"),userId=player.UserId,
    cameraType=camera and camera.CameraType.Name,subject=camera and camera.CameraSubject and camera.CameraSubject:GetFullName(),
    viewport=camera and {camera.ViewportSize.X,camera.ViewportSize.Y},screens={},items={}}
local allowed={PhuongMVPHud=true,BirthdayMoment=true,CozyAudioControls=true}
local function visible(object)
    local cursor=object
    local x,y=object.AbsolutePosition.X+object.AbsoluteSize.X/2,object.AbsolutePosition.Y+object.AbsoluteSize.Y/2
    local clipped=false
    while cursor and cursor~=pg do
        if cursor:IsA("ScreenGui") and not cursor.Enabled then return false,true end
        if cursor:IsA("GuiObject") then
            if not cursor.Visible then return false,true end
            if cursor.ClipsDescendants and cursor~=object then
                local p,s=cursor.AbsolutePosition,cursor.AbsoluteSize
                if x<p.X or x>p.X+s.X or y<p.Y or y>p.Y+s.Y then clipped=true end
            end
        end
        cursor=cursor.Parent
    end
    return true,clipped
end
for _,gui in ipairs(pg:GetChildren()) do
    if gui:IsA("ScreenGui") then table.insert(output.screens,{name=gui.Name,enabled=gui.Enabled}) end
    if allowed[gui.Name] then
        for _,item in ipairs(gui:GetDescendants()) do
            if item:IsA("TextButton") or item:IsA("TextLabel") or item:IsA("ScrollingFrame") then
                local shown,clipped=visible(item)
                if shown then
                    local entry={path=item:GetFullName(),class=item.ClassName,clipped=clipped,
                        position={item.AbsolutePosition.X,item.AbsolutePosition.Y},size={item.AbsoluteSize.X,item.AbsoluteSize.Y}}
                    if item:IsA("TextLabel") or item:IsA("TextButton") then
                        entry.text=item.Text;entry.textFits=item.TextFits
                        entry.textBounds={item.TextBounds.X,item.TextBounds.Y}
                    end
                    if item:IsA("GuiButton") then entry.active=item.Active;entry.interactable=item.Interactable end
                    if item:IsA("ScrollingFrame") then entry.scroll={item.CanvasPosition.X,item.CanvasPosition.Y};entry.canvas={item.AbsoluteCanvasSize.X,item.AbsoluteCanvasSize.Y} end
                    table.insert(output.items,entry)
                end
            end
        end
    end
end
table.sort(output.items,function(a,b) return a.path<b.path end)
return game:GetService("HttpService"):JSONEncode(output)
