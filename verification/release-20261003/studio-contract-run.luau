local source=_G.__PCW25ContractText
_G.__PCW25ContractText=nil
assert(type(source)=='string','Prepared contract source missing')
local run,err=loadstring(source,'PCW25-release-contracts')
assert(run,err)
return run()
