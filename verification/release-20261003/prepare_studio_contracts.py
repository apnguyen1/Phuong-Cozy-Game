"""Prepare temporary command-context tests after Windows blocks the CLI runner.

No DataModel instances, saved scripts, permissions or security settings change.
The same production text/specs run with Roblox's built-in Luau interpreter.
"""
from pathlib import Path
import json

HERE = Path(__file__).resolve().parent
body = (HERE / 'run_contracts.luau').read_text(encoding='utf-8')
# Roblox _G is shared user storage, unlike the standalone Luau environment.
# Capture the command's actual builtins; production module text stays unchanged.
body = body.replace('{__index=_G}', '{__index=getfenv()}')
prefix = '''local messages={}
local function print(...)
 local row={}; for i=1,select('#',...) do row[i]=tostring(select(i,...)) end
 table.insert(messages,table.concat(row,'\t'))
end
local ok,failure=xpcall(function()
'''
suffix = '''
end,debug.traceback)
return game:GetService('HttpService'):JSONEncode({ok=ok,error=not ok and tostring(failure) or nil,messages=messages})
'''
code = prefix + body + suffix
chunks = []
for offset in range(0, len(code), 36000):
    name = f'studio-contract-{len(chunks)+1:02}.luau'
    init = '_G.__PCW25ContractText=""\n' if offset == 0 else ''
    segment = json.dumps(code[offset:offset+36000],ensure_ascii=True)
    # JSON unicode escapes are not Luau escapes. Literal UTF-8 plus long brackets.
    raw = code[offset:offset+36000]
    eq = '='
    while ']' + eq + ']' in raw: eq += '='
    value = '[' + eq + '[' + raw + ']' + eq + ']'
    (HERE / name).write_text(init + '_G.__PCW25ContractText..=' + value + '\nreturn #_G.__PCW25ContractText',encoding='utf-8')
    chunks.append(name)
run = '''local source=_G.__PCW25ContractText
_G.__PCW25ContractText=nil
assert(type(source)=='string','Prepared contract source missing')
local run,err=loadstring(source,'PCW25-release-contracts')
assert(run,err)
return run()
'''
(HERE/'studio-contract-run.luau').write_text(run,encoding='utf-8')
(HERE/'studio-contract-index.json').write_text(json.dumps(chunks),encoding='utf-8')
print(json.dumps({'chunks':len(chunks),'bytes':len(code.encode())}))
