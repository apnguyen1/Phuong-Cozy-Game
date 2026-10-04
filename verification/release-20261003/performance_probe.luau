-- PCW25 read-only runtime probe. Execute in Client only; never save in the place.
-- Measures this desktop Studio client, not physical phone/group performance.
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
assert(RunService:IsClient() and RunService:IsRunning(), "Requires a playing client")
local samples, elapsed = {}, 0
local started = os.clock()
while elapsed < 12 do
    local dt = RunService.RenderStepped:Wait()
    table.insert(samples, dt)
    elapsed += dt
end
table.sort(samples)
local function percentile(fraction)
    return samples[math.clamp(math.ceil(#samples * fraction), 1, #samples)] * 1000
end
local root = workspace:FindFirstChild("CozyWorld_Draft01")
local worldParts, runtimeParts = 0, 0
local runtime = root and root:FindFirstChild("MVP") and root.MVP:FindFirstChild("RuntimePresentation")
if root then for _, item in ipairs(root:GetDescendants()) do if item:IsA("BasePart") then worldParts += 1 end end end
if runtime then for _, item in ipairs(runtime:GetDescendants()) do if item:IsA("BasePart") then runtimeParts += 1 end end end
local memoryOk, memory = pcall(Stats.GetTotalMemoryUsageMb, Stats)
return HttpService:JSONEncode({context="desktop Studio client", seconds=os.clock()-started,
    frames=#samples, averageFps=#samples/elapsed, medianFrameMs=percentile(.5),
    p95FrameMs=percentile(.95), p99FrameMs=percentile(.99),
    worldParts=worldParts, runtimeParts=runtimeParts, memoryMb=memoryOk and memory or nil,
    viewport={workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y}})
