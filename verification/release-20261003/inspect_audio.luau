-- Read-only playback evidence; this is NOT a listening/audition assertion.
local approved={ ["87992648461099"]=true,["139568344220252"]=true,
    ["88442833509532"]=true,["103516326607012"]=true,["135016436724006"]=true,["6463651038"]=true }
local sounds={}
for _,item in ipairs(game:GetService("SoundService"):GetDescendants()) do
    if item:IsA("Sound") then
        local id=item.SoundId:match("%d+")
        if approved[id] then table.insert(sounds,{path=item:GetFullName(),soundId=item.SoundId,
            loaded=item.IsLoaded,playing=item.Playing,timePosition=item.TimePosition,timeLength=item.TimeLength,
            volume=item.Volume,looped=item.Looped,playbackLoudness=item.PlaybackLoudness,
            group=item.SoundGroup and item.SoundGroup:GetFullName(),attributes=item:GetAttributes()}) end
    end
end
table.sort(sounds,function(a,b) return a.path<b.path end)
return game:GetService("HttpService"):JSONEncode({capturedAt=workspace:GetServerTimeNow(),
    context=game:GetService("RunService"):IsClient() and "Client" or "Server",placeId=game.PlaceId,sounds=sounds,
    limitation="Playback telemetry only; no listening claim"})
