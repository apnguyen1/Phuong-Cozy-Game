local function transferResult(transfer, players, roster)
 if not transfer then return false end
 local ok, result = pcall(transfer.Transfer, transfer, players, roster)
 return ok and result == true
end
local good = {Transfer = function() return true end}
local bad = {Transfer = function() error("failed") end}
local falseResult = {Transfer = function() return false end}
assert(transferResult(good, {}, {}), "successful transfer must complete")
assert(not transferResult(bad, {}, {}), "transfer errors must fail")
assert(not transferResult(falseResult, {}, {}), "false transfer must fail")
assert(not transferResult(nil, {}, {}), "missing adapter must fail")
print("transfer-result-check PASS")
