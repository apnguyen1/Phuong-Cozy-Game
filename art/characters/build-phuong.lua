-- Native Aseprite draft, drawn through the local Aseprite MCP server.
local root = 'C:/Users/andre/Repos/Phuong-Cozy-Game/'
local spr = Sprite(24, 32, ColorMode.RGB)
local legs = spr.layers[1]; legs.name = 'Legs and sneakers'
local body = spr:newLayer(); body.name = 'Shirt shorts and arms'
local hair = spr:newLayer(); hair.name = 'Hair'
local face = spr:newLayer(); face.name = 'Face glasses and bag'
local colors = {
 o='20212e', h='292d40', m='3c4258', l='505970',
 s='e7ad85', t='c78968', p='f7c89f', b='4b6076',
 c='6b8299', d='354558', k='252a34', g='454958',
 w='e7eeec', v='a5b5c0', e='171b27', r='c67977'
}
local pal = {}
for name, hex in pairs(colors) do
 pal[name]=app.pixelColor.rgba(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16),255)
end
local frontHair={
 '.....oooooo.....','...oohhhhhooo...','..ohmmmmhhhhoo..',
 '.ohmllmmhhhhhoo.','.ohmmmhhhhhhhho.','ohmmmhhhmmhhhhho',
 'ohmmhhhohhmhhhho','ohhhhho..ohhhhho','ohhhho....ohhhho',
 'ohhho......ohhho','ohhho......ohhho','ohhho......ohhho',
 '.ohho......ohho.','.ohhho....ohhho.','.ohhho....ohhho.','..ooo......ooo..'
}
local backHair={
 '.....oooooo.....','...oohhhhhooo...','..ohmmmmhhhhoo..',
 '.ohmllmmhhhhhoo.','.ohmmmhhhhhhhho.','ohmmmhhhhhhhhhho',
 'ohmmhhhhhhhhhhho','ohhhhhhhhhhhhhho','ohhhhhhhhhhhhhho',
 'ohhhhhhhhhhhhhho','ohhhhhhhhhhhhhho','ohhhhhhhhhhhhhho',
 '.ohhhhhhhhhhhho.','.ohhhhhhhhhhhho.','..ohhhhohhhhoo..','...oooo.oooo....'
}
local sideHair={
 '.....oooooo.....','...oohhhhhhoo...','..ohmmmhhhhhoo..',
 '.ohmllmmhhhhhoo.','.ohmmmhhhhhhhho.','.ohmmhhhhhhhhho.',
 '..ohhhhhhhhhhho.','...ohhhhhhhhhho.','....ohhhhhhhhho.',
 '.....ohhhhhhhho.','.....ohhhhhhhho.','.....ohhhhhhhho.',
 '.....ohhhhhhhho.','....ohhhhhhhhho.','....ohhhhhhhho..','.....oooooooo...'
}
local function rect(img,x,y,w,h,c)
 for yy=y,y+h-1 do for xx=x,x+w-1 do
  if xx>=0 and xx<24 and yy>=0 and yy<32 then img:putPixel(xx,yy,pal[c]) end
 end end
end
local function pattern(img,rows,x,y,mirror)
 for j,row in ipairs(rows) do for i=1,#row do
  local c=row:sub(i,i)
  if pal[c] then img:putPixel(x+(mirror and (16-i) or (i-1)),y+j-1,pal[c]) end
 end end
end
local function line(img,x1,y1,x2,y2,c)
 local n=math.max(math.abs(x2-x1),math.abs(y2-y1))
 for i=0,n do local t=n==0 and 0 or i/n
  rect(img,math.floor(x1+(x2-x1)*t+0.5),math.floor(y1+(y2-y1)*t+0.5),1,1,c)
 end
end
for dirIndex,dir in ipairs({'down','up','left','right'}) do
 for phase=0,4 do
  local frame=(dirIndex-1)*5+phase+1
  if frame>1 then spr:newEmptyFrame() end
  spr.frames[frame].duration=phase==0 and 0.25 or 0.14
  local imgs={Image(24,32),Image(24,32),Image(24,32),Image(24,32)}
  local leg,torso,head,detail=table.unpack(imgs)
  local bob=(phase==2 or phase==4) and -1 or 0
  local side=dir=='left' or dir=='right'
  if not side then
   local ly=(phase==1 and -1 or phase==3 and 1 or 0)
   local ry=-ly
   rect(leg,8,25,3,5+ly,'o'); rect(leg,9,25,2,4+ly,'s')
   rect(leg,13,25,3,5+ry,'o'); rect(leg,13,25,2,4+ry,'s')
   rect(leg,8,29+ly,4,2,'o'); rect(leg,8,29+ly,3,1,'w')
   rect(leg,12,29+ry,4,2,'o'); rect(leg,13,29+ry,3,1,'w')
   rect(torso,7,17+bob,10,10,'o'); rect(torso,8,18+bob,8,6,'b')
   rect(torso,9,18+bob,5,1,'c'); rect(torso,8,23+bob,8,2,'d')
   rect(torso,8,25+bob,3,1,'k'); rect(torso,13,25+bob,3,1,'k')
   local swing=phase==1 and 1 or phase==3 and -1 or 0
   rect(torso,5,18+bob+swing,3,6,'o'); rect(torso,6,19+bob+swing,2,2,'b');rect(torso,6,21+bob+swing,1,2,'s')
   rect(torso,16,18+bob-swing,3,6,'o'); rect(torso,16,19+bob-swing,2,2,'b');rect(torso,17,21+bob-swing,1,2,'s')
   if dir=='down' then
    rect(head,7,7+bob,10,8,'t'); rect(head,8,7+bob,8,7,'s');rect(head,9,8+bob,6,4,'p')
    pattern(head,frontHair,4,2+bob,false)
    rect(detail,8,9+bob,8,6,'s');rect(detail,9,9+bob,6,2,'p')
    rect(detail,9,15+bob,6,1,'s');rect(detail,10,16+bob,4,1,'t')
    rect(detail,7,10+bob,5,4,'o');rect(detail,13,10+bob,5,4,'o')
    rect(detail,8,11+bob,3,2,'s');rect(detail,14,11+bob,3,2,'s')
    rect(detail,9,11+bob,1,1,'e');rect(detail,15,11+bob,1,1,'e');rect(detail,12,11+bob,1,1,'o')
    rect(detail,11,15+bob,2,1,'r');rect(detail,10,19+bob,3,1,'v')
    line(detail,7,17+bob,16,24+bob,'o'); line(detail,7,18+bob,15,24+bob,'k')
    rect(detail,14,23+bob,4,3,'o');rect(detail,15,24+bob,2,1,'g')
   else
    pattern(head,backHair,4,2+bob,false)
    line(detail,16,17+bob,8,24+bob,'o');line(detail,16,18+bob,9,24+bob,'k')
    rect(detail,6,23+bob,4,3,'o');rect(detail,7,24+bob,2,1,'g')
   end
  else
   -- Draw left-facing geometry; reflect all layers for the right view.
   local reach=phase==1 and -2 or phase==3 and 2 or 0
   line(leg,10,25,10+reach,29,'o');line(leg,11,25,11+reach,29,'s')
   line(leg,13,25,13-reach,29,'o');line(leg,14,25,14-reach,29,'t')
   rect(leg,8+reach,29,4,2,'o');rect(leg,8+reach,29,3,1,'w')
   rect(leg,11-reach,29,4,2,'o');rect(leg,11-reach,29,3,1,'v')
   rect(torso,9,17+bob,7,10,'o');rect(torso,10,18+bob,5,6,'b');rect(torso,10,18+bob,3,1,'c')
   rect(torso,10,24+bob,5,2,'k')
   rect(head,7,8+bob,8,7,'t');rect(head,6,9+bob,6,5,'s');rect(head,5,12+bob,2,2,'s')
   pattern(head,sideHair,4,2+bob,false)
   rect(detail,7,10+bob,5,5,'s');rect(detail,7,10+bob,3,2,'p')
   rect(detail,8,15+bob,4,1,'t')
   rect(detail,5,10+bob,5,4,'o');rect(detail,6,11+bob,3,2,'s');rect(detail,6,11+bob,1,2,'e')
   rect(detail,10,11+bob,3,1,'o');rect(detail,7,15+bob,2,1,'r')
   rect(detail,11,19+bob,3,5,'o');rect(detail,12,19+bob,2,2,'c');rect(detail,12,21+bob,1,2,'s')
   line(detail,9,17+bob,14,24+bob,'o')
   if dir=='left' then rect(detail,13,23+bob,4,3,'o');rect(detail,14,24+bob,2,1,'g') end
   if dir=='right' then
    for idx,img in ipairs(imgs) do local mirrored=Image(24,32)
     for y=0,31 do for x=0,23 do mirrored:putPixel(23-x,y,img:getPixel(x,y)) end end
     imgs[idx]=mirrored
    end
   end
  end
  for idx,layer in ipairs({legs,body,hair,face}) do spr:newCel(layer,frame,imgs[idx],Point(0,0)) end
 end
end
-- Add tags after all frames exist: appending frames extends an end-of-timeline tag.
for dirIndex,dir in ipairs({'down','up','left','right'}) do
 local first=(dirIndex-1)*5+1
 local idle=spr:newTag(first,first);idle.name='idle-'..dir
 local walk=spr:newTag(first+1,first+4);walk.name='walk-'..dir
end
spr:saveAs(root..'art/characters/phuong-v1.aseprite')
print('CREATED: '..spr.width..'x'..spr.height..', '..#spr.frames..' frames, '..#spr.layers..' layers, '..#spr.tags..' tags')
