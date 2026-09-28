import base64, json, xml.etree.ElementTree as ET
from pathlib import Path
root=Path(__file__).resolve().parents[2]
xml=root/'verification/mvp/bundle-out/Phuong-Cozy-MVP-source.rbxmx'
manifest=json.loads((root/'verification/mvp/bundle-out/source-hashes.json').read_text(encoding='utf-8-sig'))
wanted={'ServerScriptService/PhuongMVP/server/activities/Q01','ServerScriptService/PhuongMVP/server/activities/Q03','StarterPlayer/StarterPlayerScripts/PhuongMVPClient'}
rows=[]
for entry,item in zip(manifest,ET.parse(xml).getroot().findall('Item')):
    if entry['target'] in wanted:
        p=item.find('Properties'); src=p.findtext("ProtectedString[@name='Source']") or ''
        rows.append((entry['target'],item.attrib['class'],base64.b64encode(src.encode()).decode()))
parts=[]
for t,c,s in rows: parts.append('{target=%r, class=%r, source=%r}'%(t,c,s))
code='''local E={%s}\nlocal A="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"\nlocal function d(v)local o,b,n={},0,0 for i=1,#v do local c=v:sub(i,i) if c~="=" then b=b*64+A:find(c,1,true)-1;n+=6;if n>=8 then n-=8;o[#o+1]=string.char(math.floor(b/(2^n))%%256);b=b%%(2^n) end end end return table.concat(o) end\nlocal function r(t)local n=game for p in t:gmatch("[^/]+") do n=n:FindFirstChild(p) if not n then return nil end end return n end\nlocal x=0 for _,e in ipairs(E) do local n=r(e.target) if not n then print("MISSING "..e.target) elseif n.ClassName~=e.class then print("CLASS "..e.target.." "..n.ClassName.."/"..e.class) elseif n.Source==d(e.source) then x+=1;print("EXACT "..e.target) else print("MISMATCH "..e.target.." actual="..#n.Source.." expected="..#d(e.source)) end end print("THREE_SOURCE_EQUALITY exact="..x.." expected="..#E)\n'''%(','.join(parts))
(root/'verification/mvp/verify_three_current.luau').write_text(code,encoding='utf-8')
print('generated',len(rows))
