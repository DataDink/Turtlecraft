-- File: global --
if(turtlecraft~=nil)then
error("A conflicting version of turtle craft exists or another script has registered 'turtlecraft'")end
turtlecraft={}turtlecraft.version=0.01;turtlecraft.directory="turtlecraft_data/"
if(not
fs.exists("turtlecraft_data"))then fs.makeDir("turtlecraft_data")end
-- File: utility --
turtlecraft.input={}
turtlecraft.input.readKey=function(a)if(a~=nil)then
os.startTimer(a)end;local b=""local c=0;repeat b,c=os.pullEvent()until
(b=="key"or b=="timer")if(b=="timer")then return nil end;return c end
turtlecraft.input.escapeOnKey=function(a,b)
local c=function()while true do local d,_a=os.pullEvent("key")
if(_a==a)then return end end end;parallel.waitForAny(c,b)end;turtlecraft.term={}
turtlecraft.term.write=function(a,b,c)
term.setCursorPos(a,b)term.clearLine()term.write(c)end
turtlecraft.term.clear=function(a,b)term.clear()local c,d=term.getSize()local _a=
"Turtlecraft v"..turtlecraft.version;if(a~=nil)then
_a=_a.." - "..a end;turtlecraft.term.write(1,1,_a)
local aa=""for i=1,c do aa=aa.."="end
turtlecraft.term.write(1,2,aa)
if(b~=nil)then turtlecraft.term.write(1,d,b)end end
turtlecraft.term.scrolled=function(a,b,c,d)local _a,aa=term.getSize()
local ba=math.max(0,c-aa+1)local ca=aa-5;local da=3;local _b=b-ba;if(_b<1 or _b>ca)then return end;turtlecraft.term.write(1,
_b+da,d)end
turtlecraft.term.notifyResume=function(a)if(a==nil)then a="previous function"end
turtlecraft.term.clear()
turtlecraft.term.write(1,4,"Resuming: "..a)
turtlecraft.term.write(1,5,"in 15 seconds.")
turtlecraft.term.write(1,6,"Press any key to cancel.")local b=turtlecraft.input.readKey(15)
turtlecraft.term.clear()return b==nil end
-- File: position --
turtlecraft.position={}
turtlecraft.scope=function()
local a={north=270,south=90,west=180,east=0,up='up',down='down'}turtlecraft.position.directions=a;local b={}b[0]=a.south
b[1]=a.west;b[2]=a.north;b[3]=a.east;turtlecraft.position.facings=b
local c={x=0,y=0,z=0,d=a.north}
local d={positionConfirmed=false,directionConfirmed=false,canSync=false,inSync=false}
local _a={path=turtlecraft.directory.."position.data"}
_a.read=function()
local aa={x=c.x,y=c.y,z=c.z,d=c.d,positionConfirmed=false,directionConfirmed=false}if(not fs.exists(_a.path))then return aa end
local ba=fs.open(_a.path,"r")if(ba==nil)then return aa end;local ca=ba.readLine()local da=ba.readLine()
ba.close()if(ca==nil)then return aa end;local _b=string.gmatch(ca,"[^,]+")
local ab={x=tonumber(_b()),y=tonumber(_b()),z=tonumber(_b()),d=tonumber(_b()),positionConfirmed=false,directionConfirmed=false}local bb=tonumber(_b())if(da==nil)then ab.positionConfirmed=true
ab.directionConfirmed=true;return ab end
_b=string.gmatch(da,"[^,]+")
local cb={x=tonumber(_b()),y=tonumber(_b()),z=tonumber(_b()),d=tonumber(_b())}
if(bb>turtle.getFuelLevel())then ab.positionConfirmed=true
ab.directionConfirmed=true elseif(bb==turtle.getFuelLevel())then ab.x=cb.x;ab.y=cb.y;ab.z=cb.z
ab.positionConfirmed=true;ab.directionConfirmed=ab.d==cb.d end;return ab end
_a.write=function(aa,ba)local ca=fs.open(_a.path,"w")if(ca==nil)then return false end
ca.writeLine(
aa.x..
","..aa.y..","..aa.z..
","..aa.d..","..turtle.getFuelLevel())
if(ba~=nil)then ca.writeLine(ba.x..
","..ba.y..","..ba.z..","..ba.d)end;ca.close()return true end
d.getPeripheral=function(aa)local ba=peripheral.getNames()for ca,da in pairs(ba)do
if(
peripheral.getType(da)==aa)then local _b=peripheral.wrap(da)return _b end end;return nil end;d.tryUpdateCustom=function()return false end
d.tryReadGps=function()local aa=""if(
peripheral.getType("right")=="modem")then aa="right"end;if(
peripheral.getType("left")=="modem")then aa="left"end
if(aa=="")then return nil end;rednet.open(aa)
if(not rednet.isOpen(aa))then return nil end;local ba,ca,da=gps.locate(10)return ba,da,ca end
d.tryUpdateGps=function()local aa,ba,ca=d.tryReadGps()if(aa==nil)then return false end;c.x=aa
c.y=ba;c.z=ca;d.positionConfirmed=true;d.canSync=true;return true end
d.tryUpdateCompass=function()local aa=d.getPeripheral("compass")if(aa==nil or
aa.getFacing==nil)then return false end
c.d=b[aa.getFacing()]d.directionConfirmed=true;return true end
d.trySync=function()
if(d.directionConfirmed and d.positionConfirmed)then return true end;if(not d.canSync)then return false end
for turns=1,4 do
if(not turtle.detect())then break end;c.d=(c.d+90)%360;turtle.turnRight()end;if(turtle.detect())then return false end;turtle.forward()
local aa=c.x;local ba=c.y;local ca=c.z;local da=c.d;if(da==a.north)then ba=ba+1 end;if(da==a.south)then
ba=ba-1 end;if(da==a.east)then aa=aa+1 end
if(da==a.west)then aa=aa-1 end;local _b,ab,bb=d.tryReadGps()
if(da==a.north and _b<aa)then da=a.west end;if(da==a.south and _b<aa)then da=a.west end;if(
da==a.east and _b<aa and ab==ba)then da=a.west end;if
(da==a.north and _b>aa)then da=a.east end
if(da==a.south and _b>aa)then da=a.east end
if(da==a.west and _b>aa and ab==ba)then da=a.east end
if(da==a.north and ab<ba and _b==aa)then da=a.south end;if(da==a.west and ab<ba)then da=a.south end;if
(da==a.east and ab<ba)then da=a.south end;if
(da==a.south and ab>ba and _b==aa)then da=a.north end
if(da==a.west and ab>ba)then da=a.north end;if(da==a.east and ab>ba)then da=a.north end
turtle.back()c.d=da;_a.write(c)return true end
c.init=function()local aa=_a.read()c.x=aa.x;c.y=aa.y;c.z=aa.z;c.d=aa.d
d.positionConfirmed=aa.positionConfirmed;d.directionConfirmed=aa.directionConfirmed;if(not d.tryUpdateCustom())then
d.tryUpdateGps()d.tryUpdateCompass()end
d.inSync=(
d.positionConfirmed and d.directionConfirmed)or d.trySync()end;c.init()
turtlecraft.position.isInSync=function()return d.inSync end
turtlecraft.position.syncTo=function(aa,ba,ca,da)c.x=aa;c.y=ba;c.z=ca;c.d=da;d.inSync=true end
turtlecraft.position.get=function()return c.x,c.y,c.z,c.d end
turtlecraft.position.set=function(aa,ba,ca,da,_b)if(type(da)~="number")then da=c.d end
local ab={x=c.x,y=c.y,z=c.z,d=c.d}local bb={x=aa,y=ba,z=ca,d=da}_a.write(bb,ab)if
(_b==nil or _b()==false)then _a.write(ab)return false end;_a.write(bb)
c.x=aa;c.y=ba;c.z=ca;c.d=da;return true end end;turtlecraft.scope()
-- File: fuel --
turtlecraft.fuel={}
turtlecraft.scope=function()
local a={fuelSlot=1,fuelPerBurn=0,itemsPerBurn=1}
a.getRefuelCount=function()return turtle.getItemCount(a.fuelSlot)end
a.burn=function()turtle.select(a.fuelSlot)
local b=turtle.getFuelLevel()
if(not turtle.refuel(a.itemsPerBurn))then return false end;local c=turtle.getFuelLevel()a.fuelPerBurn=c-b;return true end
turtlecraft.fuel.estimateRemaining=function()local b=turtle.getFuelLevel()
local c=a.getRefuelCount()local d=c*a.fuelPerBurn;return b+d end
turtlecraft.fuel.require=function(b)if(b==nil)then b=1 end
while
(turtle.getFuelLevel()<b)do
if(not a.burn())then
print("Turtle ran out of fuel! Please put more in slot 1")while(not a.burn())do sleep(5)end end end end end;turtlecraft.scope()
-- File: move --
turtlecraft.move={}
turtlecraft.scope=function()local a={}
local b=turtlecraft.position.directions
a.face=function(c)if(c==b.up or c==b.down)then return true end
local _a,aa,ba,ca=turtlecraft.position.get()if(ca==c)then return true end;if(ca%90 ~=0)then
error("Facing directions must be multiples of 90 degrees")end
if( (ca+270)%360 ==c)then
turtlecraft.position.set(_a,aa,ba,c,turtle.turnLeft)else while(ca~=c)do ca=(ca+90)%360
turtlecraft.position.set(_a,aa,ba,ca,turtle.turnRight)end end;return true end;a.dig=function()
return(not turtle.detect())or turtle.dig()end
a.digUp=function()return(not
turtle.detectUp())or turtle.digUp()end
a.digDown=function()return
(not turtle.detectDown())or turtle.digDown()end
a.excavate=function()a.digUp()a.digDown()return a.dig()end
a.excavateUp=function()a.dig()a.digDown()return a.digUp()end
a.excavateDown=function()a.dig()a.digUp()return a.digDown()end
a.move=function(c,d,_a,aa)local ba=turtle.forward;if(c==b.up)then ba=turtle.up end;if(c==b.down)then
ba=turtle.down end
local ca,da,_b,ab=turtlecraft.position.get()if(c==b.up)then _b=_b+1 end;if(c==b.down)then _b=_b-1 end;if(c==b.north)then
da=da+1 end;if(c==b.south)then da=da-1 end
if(c==b.east)then ca=ca+1 end;if(c==b.west)then ca=ca-1 end
local bb=function()
turtlecraft.fuel.require(1)while(not ba())do if(aa~=nil and aa(c)==false)then return false end
sleep(.01)end;return true end;a.face(c)if(d~=nil and d(c)==false)then return false end;if(
turtlecraft.position.set(ca,da,_b,c,bb)==false)then return false end;if(
_a~=nil and _a(c)==false)then return false end;return true end
a.repeatMove=function(c,d,_a,aa,ba,ca,da)local _b=d-c;local ab=_a;if(_b<0)then ab=aa end;for i=1,math.abs(_b)do if
(a.move(ab,ba,ca,da)==false)then return false end end;return
true end
a.moveTo=function(c,d,_a,aa,ba,ca)local da,_b,ab,bb=turtlecraft.position.get()if(
a.repeatMove(da,c,b.east,b.west,aa,ba,ca)==false)then return false end
if(
a.repeatMove(_b,d,b.north,b.south,aa,ba,ca)==false)then return false end
if(a.repeatMove(ab,_a,b.up,b.down,aa,ba,ca)==false)then return false end;return true end
turtlecraft.move.face=function(c)return a.face(c)end
turtlecraft.move.to=function(c,d,_a,aa)return a.moveTo(c,d,_a,nil,aa,nil)end
turtlecraft.move.digTo=function(c,d,_a,aa)
local ba=function(ca)if(ca==b.up)then return a.digUp()elseif(ca==b.down)then
return a.digDown()else return a.dig()end end;return a.moveTo(c,d,_a,ba,aa,ba)end
turtlecraft.move.excavateTo=function(c,d,_a,aa)
local ba=function(ca)
if(ca==b.up)then return a.excavateUp()elseif(ca==b.down)then return
a.excavateDown()else return a.excavate()end end;return a.moveTo(c,d,_a,ba,aa,ba)end end;turtlecraft.scope()
-- File: excavate --
turtlecraft.excavate={}
turtlecraft.scope=function()local a=turtlecraft.position
local b=a.directions;local c=turtlecraft.term;local d={}local _a={}local aa={}
_a.path=turtlecraft.directory.."excavate.data"
_a.init=function(ca,da,_b,ab,bb)local cb,db,_c,ac=a.get()
_a.home={x=cb,y=db,z=_c,d=(ac+180)%360}_a.step={x=1,y=1,z=-3}
_a.min={x=cb,y=db,z=_c-math.abs(bb)+1}_a.max={x=cb,y=db,z=_c+math.abs(ab)-1}
if(ac==
b.north)then _a.max.y=_a.max.y+math.abs(ca)_a.min.x=
_a.min.x-math.abs(da)
_a.max.x=_a.max.x+math.abs(_b)elseif(ac==b.south)then _a.min.y=_a.min.y-math.abs(ca)_a.min.x=
_a.min.x-math.abs(_b)
_a.max.x=_a.max.x+math.abs(da)elseif(ac==b.east)then _a.max.x=_a.max.x+math.abs(ca)_a.min.y=
_a.min.y-math.abs(_b)
_a.max.y=_a.max.y+math.abs(da)else _a.min.x=_a.min.x-math.abs(ca)_a.min.y=_a.min.y-
math.abs(da)
_a.max.y=_a.max.y+math.abs(_b)end;_a.progress={x=_a.min.x,y=_a.min.y,z=_a.max.z}end
_a.update=function()local ca,da,_b,ab=a.get()_a.progress={x=ca,y=da,z=_b}
local bb=fs.open(_a.path,"w")
bb.writeLine(_a.home.x..",".._a.home.y..
",".._a.home.z..",".._a.home.d)bb.writeLine(ca..","..da..",".._b)
bb.writeLine(
_a.min.x..",".._a.min.y..",".._a.min.z)
bb.writeLine(_a.max.x..",".._a.max.y..",".._a.max.z)
bb.writeLine(_a.step.x..",".._a.step.y..",".._a.step.z)bb.close()end
_a.reset=function()fs.delete(_a.path)local ca,da,_b,ab=a.get()
_a.home={x=ca,y=da,z=_b,d=(ab+180)%360}_a.progress={x=ca,y=da,z=_b}_a.min={x=ca,y=da,z=_b}
_a.max={x=ca,y=da,z=_b}_a.step={x=1,y=1,z=-3}end
_a.recover=function()if(not fs.exists(_a.path))then return false end
local ca=fs.open(_a.path,"r")local da=ca.readLine()local _b=ca.readLine()local ab=ca.readLine()
local bb=ca.readLine()local cb=ca.readLine()ca.close()
if(

(not a.isInSync())or da==nil or _b==nil or ab==nil or bb==nil or cb==nil)then
print("Warning: Unable to resume dig")return false end;local db="[^,]+"local _c={home=da,progress=_b,min=ab,max=bb,step=cb}
for ac,bc in pairs(_c)do
local cc=string.gmatch(bc,db)if(_a[ac]==nil)then _a[ac]={}end;local dc=_a[ac]
dc.x=tonumber(cc()or 0)dc.y=tonumber(cc()or 0)dc.z=tonumber(cc()or 0)dc.d=tonumber(
cc()or"")end;fs.delete(_a.path)return true end
_a.calcDistance=function(ca,da,_b)local ab,bb,cb,db=a.get()local _c=math.abs(ab-ca)
local ac=math.abs(bb-da)local bc=math.abs(cb-_b)return _c+ac+bc+5 end;_a.calcReturn=function()
return _a.calcDistance(_a.home.x,_a.home.y,_a.home.z)end
d.calcRemainingSlots=function()
local ca=0
for i=2,16 do if(turtle.getItemCount(i)==0)then ca=ca+1 end end;return ca end
d.needsUnload=function()return d.calcRemainingSlots()==0 end
d.unload=function()turtlecraft.move.face(_a.home.d)for i=2,16 do
if(
turtle.getItemCount(i)>0)then turtle.select(i)if(not turtle.drop())then
error("Fatal Error: Can't unload inventory.")end end end end
aa.home=function(ca)
turtlecraft.move.digTo(_a.home.x,_a.home.y,_a.home.z)ca()
turtlecraft.move.face((_a.home.d+180)%360)
turtlecraft.move.digTo(_a.progress.x,_a.progress.y,_a.progress.z)end
aa.finish=function()fs.delete(_a.path)
turtlecraft.move.digTo(_a.home.x,_a.home.y,_a.home.z)turtlecraft.move.face(_a.home.d)
d.unload()turtle.select(1)turtle.drop()turtlecraft.move.face((
_a.home.d+180)%360)
_a.reset()end
aa.next=function()
local ca=_a.calcDistance(_a.progress.x,_a.progress.y,_a.progress.z)local da=_a.calcReturn()
local _b=turtlecraft.fuel.estimateRemaining()
if(d.needsUnload()or _b<=ca or _b<=da)then
aa.home(function()
local cb=_a.calcDistance(_a.progress.x,_a.progress.y,_a.progress.z)turtlecraft.fuel.require(cb)d.unload()end)end
if(not
turtlecraft.move.digTo(_a.progress.x,_a.progress.y,_a.progress.z))then aa.finish()return false end;local ab=turtlecraft.move.excavateTo
local bb={x=_a.progress.x,y=_a.progress.y,z=_a.progress.z}bb.x=bb.x+_a.step.x
if
(bb.x>_a.max.x or bb.x<_a.min.x)then _a.step.x=-_a.step.x;bb.x=bb.x+_a.step.x;bb.y=
_a.progress.y+_a.step.y
if
(bb.y>_a.max.y or bb.y<_a.min.y)then _a.step.y=-_a.step.y;bb.y=bb.y+_a.step.y;bb.z=bb.z+
_a.step.z;ab=turtlecraft.move.digTo
turtle.digUp()if(bb.z==_a.min.z-1 or bb.z==_a.min.z-2)then
bb.z=_a.min.z end
if(bb.z<_a.min.z)then aa.finish()return false end end end
if(not ab(bb.x,bb.y,bb.z))then print("move failed")
local cb,db,_c,ac=turtlecraft.position.get()
if(cb==_a.progress.x and db==_a.progress.y and _c==
_a.progress.z)then
print("Unable to dig further")aa.finish()return false end end;_a.update()return true end
aa.start=function(ca,da,_b,ab,bb)_a.init(ca,da,_b,ab,bb)
turtlecraft.term.write(1,5,"Press Q to cancel")
turtlecraft.input.escapeOnKey(16,function()while(aa.next())do sleep(0.001)end end)_a.reset()end
local ba=function(ca,da)term.setCursorPos(ca,da)
local _b=tonumber(read()or"")if(_b==nil)then return 0 end;return _b end
if(_a.recover())then
if(not c.notifyResume("excavating"))then
c.clear("Excavate")c.write(1,5,"Excavate cancelled...")sleep(3)return end;c.clear("Excavate")
c.write(1,5,"Resuming excavate...")term.setCursorPos(1,6)
while(aa.next())do sleep(0.001)end end
turtlecraft.excavate.start=function()c.clear("Excavate")
c.write(1,4,"How far forward?")local ca=ba(18,4)if(ca==0)then return false end
c.write(1,4,"How far left?")local da=ba(15,4)c.write(1,4,"How far right?")local _b=ba(16,4)if(
da==0 and _b==0)then return false end
c.write(1,4,"How far up?")local ab=ba(13,4)c.write(1,4,"How far down?")local bb=ba(15,4)if(ab==0 and
bb==0)then return false end;c.clear("Excavate")
aa.start(ca,da,_b,ab,bb)c.clear("Excavate")
c.write(1,4,"Digging is complete.")c.write(1,5,"Press any key to continue.")
term.setCursorPos(0,0)turtlecraft.input.readKey(10)end;turtlecraft.excavate.debug={}turtlecraft.excavate.debug.start=function(ca,da,_b,ab,bb)
aa.start(ca,da,_b,ab,bb)end end;turtlecraft.scope()
-- File: seeker --
turtlecraft.seeker={}
turtlecraft.scope=function()
local a=turtlecraft.directory.."seeker.data"
local b=function(ab)turtle.turnRight()turtle.turnRight()local bb=ab()
turtle.turnRight()turtle.turnRight()return bb end;local c={up="up",down="down",forward="forward"}
local d={turtle.turnRight,turtle.turnLeft,turtle.turnLeft,turtle.turnLeft}local _a={}
_a.write=function(ab,bb)local cb=fs.open(a,"w")cb.write(ab..","..bb)
cb.close()end;_a.complete=function()fs.delete(a)end
_a.read=function()if
(not fs.exists(a))then return nil end;local ab=fs.open(a,"r")
local bb=ab.readLine()ab.close()if(bb==nil)then return nil end
local cb=string.gmatch(bb,"[^,]+")return cb(),cb()end
local aa=function()local ab=0
while true do for i=1,16 do
if(turtle.getItemCount(i)==0)then sleep(ab)return end end;ab=15
turtlecraft.term.clear("Inventory")
turtlecraft.term.write(1,5,"Please unload me...")sleep(1)end end
local ba=function()local ab=0
while true do
for i=2,16 do if(turtle.getItemCount(i)>0)then sleep(ab)
if(
turtle.getItemCount(i)>0)then turtle.select(i)return i end end end;ab=15;turtlecraft.term.clear("Inventory")
turtlecraft.term.write(1,5,"Please add more inventory...")sleep(1)end end
local ca=function(ab,bb)
if(bb==nil)then bb=c.down;if
(turtle.detectUp()and not turtle.detectDown())then bb=c.up end end
if(ab and turtle.getItemCount(2)==0)then
turtle.select(2)turtlecraft.fuel.require(1)
if(turtle.detectUp())then
turtle.digUp()turtle.up()elseif(turtle.detectDown())then turtle.digDown()
turtle.down()else turtlecraft.term.clear()
turtlecraft.term.write(1,5,"I need a sample block to unfill with.")turtlecraft.input.readKey(5)return end;_a.write("unfill",bb)else _a.write("eat",bb)end;local cb=turtle.detectUp;local db=turtle.detectDown;local _c=turtle.detect
if(ab)then
cb=function()
turtle.select(2)return turtle.compareUp()end
db=function()turtle.select(2)return turtle.compareDown()end
_c=function()turtle.select(2)return turtle.compare()end end;local ac={move=turtle.up,detect=cb,dig=turtle.digUp}
local bc={move=turtle.down,detect=db,dig=turtle.digDown}
if(bb==c.up)then
ac={move=turtle.down,detect=db,dig=turtle.digDown}bc={move=turtle.up,detect=cb,dig=turtle.digUp}end
local cc=function()for _d,ad in pairs(d)do ad()if(_c())then return true end end
return false end
local dc=function()ac.move()
for vert=1,3 do
for horz=1,4 do turtlecraft.fuel.require(2)
turtle.forward()turtle.forward()if
(ac.detect()or bc.detect()or cc())then return true end;turtle.turnLeft()end;bc.move()end;return false end;turtlecraft.term.clear("Munch Munch")
turtlecraft.term.write(1,5,"Press Q to stop")
turtlecraft.input.escapeOnKey(16,function()
while true do
turtlecraft.fuel.require(1)aa()
if(ac.detect())then ac.dig()ac.move()elseif(cc())then while(_c()and turtle.dig())do
sleep(0.5)end;turtle.forward()elseif(bc.detect())then while(bc.detect()and
bc.dig())do sleep(0.5)end;bc.move()elseif(not dc())then
turtlecraft.term.clear("All Gone?")turtlecraft.term.write(1,5,"I got lost!")
turtlecraft.input.readKey(10)return end end end)_a.complete()end
turtlecraft.seeker.eat=function(ab)ca(false,ab)end
turtlecraft.seeker.unfill=function(ab)ca(true,ab)end
turtlecraft.seeker.fill=function(ab)
if(ab==nil)then ab=c.down;if(turtle.detectDown()and not
turtle.detectUp())then ab=c.up end end;_a.write("fill",ab)
local bb={move=turtle.up,detect=turtle.detectUp}
local cb={move=turtle.down,detect=turtle.detectDown,place=turtle.placeUp}if(ab==c.up)then bb={move=turtle.down,detect=turtle.detectDown}
cb={move=turtle.up,detect=turtle.detectUp,place=turtle.placeDown}end
local db=function()
for _c,ac in pairs(d)do
ac()if(turtle.back())then return true end end;return false end;turtlecraft.term.clear("Fill")
turtlecraft.term.write(1,5,"Press Q to stop")
turtlecraft.input.escapeOnKey(16,function()
while true do
turtlecraft.fuel.require(1)
if(not bb.detect())then bb.move()elseif(db())then ba()turtle.place()else
turtle.turnLeft()turtle.turnLeft()
if(cb.detect())then
turtlecraft.term.write(1,5,"I got stuck!")
turtlecraft.term.write(1,6,"Press any key to continue")turtlecraft.input.readKey()return end;cb.move()ba()cb.place()end end end)_a.complete()end;local da,_b=_a.read()if(da~=nil)then
turtlecraft.seeker[da](_b)end end;turtlecraft.scope()
-- File: builder --
turtlecraft.builder={}
turtlecraft.scope=function()
local a=turtlecraft.directory.."project.data"local b=turtlecraft.directory.."builder.data"local c={}
c.data={}
c.load=function()if(not fs.exists(a))then return false end;local ab=
fs.open(a,"r").readAll()or""c.data={}
local bb=string.gmatch(ab,"[^,]+")
for cb in bb do
local db={x=tonumber(cb),y=tonumber(bb()),z=tonumber(bb())}table.insert(c.data,db)end;return true end
c.save=function()local ab=""for cb,db in ipairs(c.data)do ab=ab..
db.x..","..db.y..","..db.z..","end
local bb=fs.open(a,"w")bb.write(ab)bb.close()end;c.clear=function()c.data={}fs.delete(a)end
c.load()local d={}d.isEnabled=function()return fs.exists(b)end
d.set=function(ab)
local bb=fs.open(b,"w")
bb.write(ab.x..","..ab.y..","..ab.z)bb.close()end
d.get=function()local ab=fs.open(b,"r")
local bb=string.gmatch(ab.readAll(),"[^,]+")ab.close()return
{x=tonumber(bb()),y=tonumber(bb()),z=tonumber(bb())}end;d.disable=function()fs.delete(b)end;local _a={}
_a.round=function(ab)
if
(ab%1 >=0.5)then return math.ceil(ab)else return math.floor(ab)end end
_a.plot=function(ab,bb)return{h=math.cos(math.rad(ab))*bb,v=
math.sin(math.rad(ab))*bb}end
_a.measure=function(ab,bb,cb)if(ab==nil)then ab=0 end;if(bb==nil)then bb=0 end;if(cb==nil)then cb=0 end;return math.sqrt(
ab*ab+bb*bb+cb*cb)end;_a.angleStep=function(ab)return(45 /ab)/2 end
_a.rotateVector=function(ab,bb,cb,db)if(bb==
nil)then bb=0 end;if(cb==nil)then cb=0 end;if(db==nil)then db=0 end;if(
bb==0 and cb==0 and db==0)then return end
if(bb~=0)then
local _c=math.cos(math.rad(bb))local ac=math.sin(math.rad(bb))
local bc=_c*ab.z-ac*ab.y;local cc=ac*ab.z+_c*ab.y;ab.z=bc;ab.y=cc end
if(cb~=0)then local _c=math.cos(math.rad(cb))
local ac=math.sin(math.rad(cb))local bc=_c*ab.x-ac*ab.z;local cc=ac*ab.x+_c*ab.z
ab.x=bc;ab.z=cc end
if(db~=0)then local _c=math.cos(math.rad(db))
local ac=math.sin(math.rad(db))local bc=_c*ab.x-ac*ab.y;local cc=ac*ab.x+_c*ab.y
ab.x=bc;ab.y=cc end end
_a.scaleVector=function(ab,bb,cb,db)if(bb==nil)then bb=1 end;if(cb==nil)then cb=1 end
if(db==nil)then db=1 end;if(bb==1 and cb==1 and db==1)then return end;ab.x=ab.x*bb;ab.y=
ab.y*cb;ab.z=ab.z*db end
_a.roundVector=function(ab)ab.x=_a.round(ab.x)ab.y=_a.round(ab.y)
ab.z=_a.round(ab.z)end
_a.line=function(ab,bb)local cb={}
local db={x=bb.x-ab.x,y=bb.y-ab.y,z=bb.z-ab.z}local _c=_a.measure(db.x,db.y,db.z)for d=0,_c,0.5 do
table.insert(cb,{x=ab.x+db.x/_c*d,y=
ab.y+db.y/_c*d,z=ab.z+db.z/_c*d})end;return cb end
_a.bounds=function(ab)local bb=0;local cb=0;local db=0;local _c=0;local ac=0;local bc=0
for cc,dc in ipairs(ab)do
if(dc.x<bb)then bb=dc.x end;if(dc.x>cb)then cb=dc.x end;if(dc.y>db)then db=dc.y end
if(dc.y<_c)then _c=dc.y end;if(dc.z>ac)then ac=dc.z end;if(dc.z<bc)then bc=dc.z end end;return db,_c,cb,bb,ac,bc end;local aa={}
aa.concat=function(ab,bb)local cb={}
for db,_c in ipairs(ab)do table.insert(cb,_c)end;for db,_c in ipairs(bb)do table.insert(cb,_c)end;return cb end
aa.group=function(ab,bb)local cb={}local db={}
for ac,bc in ipairs(ab)do local cc=bb(bc)
if(db[cc]==nil)then db[cc]={}end;table.insert(db[cc],bc)end;local _c={}for ac in pairs(db)do table.insert(_c,ac)end
table.sort(_c)for ac,bc in ipairs(_c)do table.insert(cb,db[bc])end
return cb end
aa.extractNearestVector=function(ab,bb)
if(ab==nill or bb==nil or ab[1]==nil)then return nil end;local cb=0;local db=nil
for _c,ac in ipairs(ab)do
local bc=_a.measure(ac.x-bb.x,ac.y-bb.y,ac.z-bb.z)if(db==nil or bc<db)then db=bc;cb=_c end end;return table.remove(ab,cb)end
aa.sortVectors=function(ab)local bb={}
local cb=aa.group(ab,function(db)return db.z end)
for db,_c in ipairs(cb)do local ac={}
local bc=aa.group(_c,function(cc)return cc.y end)
for cc,dc in ipairs(bc)do
local _d=aa.group(dc,function(ad)return ad.x end)for ad,bd in ipairs(_d)do table.insert(ac,bd[1])end end
if(ac[1]~=nil)then local cc=table.remove(ac,1)table.insert(bb,cc)while(
ac[1]~=nil)do cc=aa.extractNearestVector(ac,cc)
table.insert(bb,cc)end end end;return bb end;local ba={}ba.line=function(ab)
return _a.line({x=-ab,y=0,z=0},{x=ab,y=0,z=0})end
ba.circle=function(ab)
local bb={}local cb=_a.angleStep(ab)for angle=0,360,cb do local db=_a.plot(angle,ab)
table.insert(bb,{x=db.h,y=db.v,z=0})end;return bb end
ba.polygon=function(ab,bb)if(bb<3)then return nil end;local cb={}local db=360 /bb;local _c=nil
for angle=0,360,db do
corner=_a.plot(angle,ab)if(_c~=nil)then
cb=aa.concat(cb,_a.line({x=_c.h,y=_c.v,z=0},{x=corner.h,y=corner.v,z=0}))end;_c=corner end;return cb end;local ca={}
ca.tube=function(ab,bb)local cb={}for z=-ab,ab do for db,_c in ipairs(bb)do
table.insert(cb,{x=_c.x,y=_c.y,z=z})end end;return
cb end
ca.cone=function(ab,bb)local cb={}
for z=-ab,ab do local db=1 /ab*2 *math.abs(z-ab)for _c,ac in
ipairs(bb)do
table.insert(cb,{x=ac.x*db,y=ac.y*db,z=z})end end;return cb end
ca.sphere=function(ab,bb)local cb={}local db=_a.angleStep(ab)
for angle=0,180,db do local _c=_a.plot(angle,ab)
local ac=_c.h;local bc=_c.v/ab;for cc,dc in ipairs(bb)do
table.insert(cb,{x=dc.x*bc,y=dc.y*bc,z=ac})end end;return cb end
ca.torus=function(ab,bb)local cb={}local db=_a.angleStep(ab)local _c=0;for bc,cc in ipairs(bb)do
if(cc.x<_c)then _c=cc.x end end;local ac=ab-_c;for bc,cc in ipairs(bb)do cc.x=cc.x-ac
table.insert(cb,cc)end;for angle=0,360,db do
for bc,cc in ipairs(bb)do
local dc={x=cc.x,y=cc.y,z=cc.z}_a.rotateVector(dc,0,angle,0)table.insert(cb,dc)end end;return cb end
local da=function()local ab=0
while true do
for i=2,16 do if(turtle.getItemCount(i)>0)then sleep(ab)
if(
turtle.getItemCount(i)>0)then turtle.select(i)return i end end end;ab=15;turtlecraft.term.clear("Inventory")
turtlecraft.term.write(1,5,"Please add more inventory...")sleep(1)end end
local _b=function(ab)turtlecraft.term.clear("Build Project")
turtlecraft.term.write(1,4,"Press Q to cancel")
turtlecraft.input.escapeOnKey(16,function()local bb=false
local cb,db,_c,ac=turtlecraft.position.get()
for bc,cc in ipairs(c.data)do
local dc={x=cc.x+ab.x,y=cc.y+ab.y,z=cc.z+ab.z}
if(not bb)then
bb=dc.x==cb and dc.y==db and dc.z==_c else turtlecraft.move.digTo(dc.x,dc.y,dc.z)if
(turtle.detectDown())then turtle.digDown()end;da()
turtle.placeDown()end end end)d.disable()end
turtlecraft.builder.clear=function()
turtlecraft.term.clear("Delete Project")
turtlecraft.term.write(1,4,"You will lose all stored data.")
turtlecraft.term.write(1,5,"Are you sure? (y, n): ")
if(read()=="y")then c.data={}c.save()
turtlecraft.term.clear("Delete Project")
turtlecraft.term.write(1,4,"Project erased!")turtlecraft.input.readKey(5)else
turtlecraft.term.clear("Delete Project")
turtlecraft.term.write(1,4,"Erase cancelled!")turtlecraft.input.readKey(5)end end
turtlecraft.builder.stats=function()
turtlecraft.term.clear("Project Info")local ab=table.getn(c.data)
if(ab==0)then
turtlecraft.term.write(1,4,"Your project is empty")turtlecraft.input.readKey(5)return end;local bb,cb,db,_c,ac,bc=_a.bounds(c.data)
turtlecraft.term.write(1,4,"Block Count: "..ab)
turtlecraft.term.write(1,5,math.abs(bb).." blocks north.")
turtlecraft.term.write(1,6,math.abs(cb).." blocks south.")
turtlecraft.term.write(1,7,math.abs(db).." blocks east.")
turtlecraft.term.write(1,8,math.abs(_c).." blocks west.")
turtlecraft.term.write(1,9,math.abs(ac).." blocks up.")
turtlecraft.term.write(1,10,math.abs(bc).." blocks down.")turtlecraft.input.readKey(15)end
turtlecraft.builder.start=function()if(table.getn(c.data)==0)then
turtlecraft.term.write(1,4,"Your project is empty")sleep(5)return end
local ab=c.data[1]local bb,cb,db,_c=turtlecraft.position.get()
local ac={x=bb,y=cb,z=db}d.set(ac)
turtlecraft.move.digTo(ab.x+ac.x,ab.y+ac.y,ab.z+ac.z)_b(ac)end
turtlecraft.builder.trim=function()
turtlecraft.term.clear("Trim")
turtlecraft.term.write(1,4,"This will allow you to trim off")
turtlecraft.term.write(1,5,"blocks from the sides of your project.")local ab,bb,cb,db,_c,ac=_a.bounds(c.data)
turtlecraft.term.write(1,6,"How much from the north?")
turtlecraft.term.write(1,7,"(0-"..math.abs(ab).."): ")local bc=ab-
math.max(0,math.min(math.abs(ab),tonumber(read()or 0)))
turtlecraft.term.write(1,6,"How much from the south?")
turtlecraft.term.write(1,7,"(0-"..math.abs(bb).."): ")local cc=bb+
math.max(0,math.min(math.abs(bb),tonumber(read()or 0)))
turtlecraft.term.write(1,6,"How much from the east?")
turtlecraft.term.write(1,7,"(0-"..math.abs(cb).."): ")local dc=cb-
math.max(0,math.min(math.abs(cb),tonumber(read()or 0)))
turtlecraft.term.write(1,6,"How much from the west?")
turtlecraft.term.write(1,7,"(0-"..math.abs(db).."): ")local _d=db+
math.max(0,math.min(math.abs(db),tonumber(read()or 0)))
turtlecraft.term.write(1,6,"How much from the up?")
turtlecraft.term.write(1,7,"(0-"..math.abs(_c).."): ")local ad=_c-
math.max(0,math.min(math.abs(_c),tonumber(read()or 0)))
turtlecraft.term.write(1,6,"How much from the down?")
turtlecraft.term.write(1,7,"(0-"..math.abs(ac).."): ")local bd=ac+
math.max(0,math.min(math.abs(ac),tonumber(read()or 0)))
turtlecraft.term.clear("Trim")
turtlecraft.term.write(1,4,"Calculating...")local cd={}
for dd,__a in ipairs(c.data)do if(

__a.y<=bc and __a.y>=cc and __a.x<=dc and __a.x>=_d and __a.z<=ad and __a.z>=bd)then
table.insert(cd,__a)end end;c.data=cd;c.save()
turtlecraft.term.clear("Trim")
turtlecraft.term.write(1,4,"Trim complete!")turtlecraft.input.readKey(5)end
turtlecraft.builder.add=function()
turtlecraft.term.clear("Add Shape")
turtlecraft.term.write(1,4,"To create a shape you must select")
turtlecraft.term.write(1,5,"how many sides you want your base")
turtlecraft.term.write(1,6,"2D shape to be: (0 = circle, 1 = line)")turtlecraft.term.write(1,7,"Sides: ")local ab=tonumber(
read()or 0)local bb=ba.circle
if(ab==1)then bb=ba.line end;if(ab>1)then
bb=function(c_a)return ba.polygon(c_a,ab)end end
turtlecraft.term.clear("Radius")
turtlecraft.term.write(1,4,"Now choose the radius of your base")
turtlecraft.term.write(1,5,"shape. (Radius is from center to edge)")turtlecraft.term.write(1,6,"Radius: ")local cb=math.abs(tonumber(
read()or 0))if(cb==0)then return end
turtlecraft.term.clear("Extrude Shape")
turtlecraft.term.write(1,4,"Now you must choose how to extrude your")
turtlecraft.term.write(1,5,"2D shape into a 3D shape: ")
turtlecraft.term.write(1,7,"1 = tube, 2 = cone, ")
turtlecraft.term.write(1,8,"3 = sphere, 4 = torus")
turtlecraft.term.write(1,9,"Enter nothing to keep this a 2D shape.")turtlecraft.term.write(1,10,"Extrusion: ")
local db={"tube","cone","sphere","torus"}local _c=read()or""local ac=tonumber(_c or 0)for c_a,d_a in ipairs(db)do
if(ac==c_a)then _c=d_a;break end;if(_c==d_a)then break end end
local bc=function(c_a,d_a)return d_a end;if(ca[_c]~=nil)then bc=ca[_c]end;local cc={}
if(_c=="torus")then
turtlecraft.term.clear("Extrude Shape")
turtlecraft.term.write(1,4,"I need a radius for your torus.")turtlecraft.term.write(1,5,"Radius: ")local c_a=math.abs(tonumber(
read()or 0))if(c_a==0)then return end
cc=bc(c_a,bb(cb))else cc=bc(cb,bb(cb))end;local dc=1;local _d=1;local ad=1
turtlecraft.term.clear("Scale Shape")
turtlecraft.term.write(1,4,"Would you like to squish your shape?")turtlecraft.term.write(1,5,"(y or n): ")
if(
read()=="y")then
turtlecraft.term.write(1,4,"Squish east-west...")turtlecraft.term.write(1,5,"(0 - 100): ")
dc=math.max(0,math.min(100,tonumber(
read()or 0)))/100
turtlecraft.term.write(1,4,"Squish north-south...")turtlecraft.term.write(1,5,"(0 - 100): ")
_d=math.max(0,math.min(100,tonumber(
read()or 0)))/100
turtlecraft.term.write(1,4,"Squish up-down...")turtlecraft.term.write(1,5,"(0 - 100): ")
ad=math.max(0,math.min(100,tonumber(
read()or 0)))/100 end;local bd=0;local cd=0;local dd=0
turtlecraft.term.clear("Rotate Shape")
turtlecraft.term.write(1,4,"Would you like to turn your shape?")turtlecraft.term.write(1,5,"(y or n): ")
if(
read()=="y")then
turtlecraft.term.write(1,4,"Rotate east-west axis...")turtlecraft.term.write(1,5,"(0 - 360): ")
bd=math.max(0,math.min(360,tonumber(
read()or 0)))
turtlecraft.term.write(1,4,"Rotate north-south axis...")turtlecraft.term.write(1,5,"(0 - 360): ")
cd=math.max(0,math.min(360,tonumber(
read()or 0)))
turtlecraft.term.write(1,4,"Rotate up-down axis...")turtlecraft.term.write(1,5,"(0 - 360): ")
dd=math.max(0,math.min(360,tonumber(
read()or 0)))end;local __a=0;local a_a=0;local b_a=0
turtlecraft.term.clear("Offset Shape")
turtlecraft.term.write(1,4,"Would you like to offset your shape?")turtlecraft.term.write(1,5,"(y or n): ")
if(
read()=="y")then
turtlecraft.term.write(1,4,"Offset east-west...")
turtlecraft.term.write(1,5,"(-500 to 500): ")
__a=math.max(-500,math.min(500,tonumber(read()or 0)))
turtlecraft.term.write(1,4,"Offset north-south...")
turtlecraft.term.write(1,5,"(-500 to 500): ")
a_a=math.max(-500,math.min(500,tonumber(read()or 0)))
turtlecraft.term.write(1,4,"Offset up-down...")
turtlecraft.term.write(1,5,"(-500 to 500): ")
b_a=math.max(-500,math.min(500,tonumber(read()or 0)))end
turtlecraft.term.clear("Generating Shape")
turtlecraft.term.write(1,4,"Generating your shape...")
for c_a,d_a in ipairs(cc)do _a.scaleVector(d_a,dc,_d,ad)
_a.rotateVector(d_a,bd,cd,dd)d_a.x=d_a.x+__a;d_a.y=d_a.y+a_a;d_a.z=d_a.z+b_a
_a.roundVector(d_a)table.insert(c.data,d_a)end;c.data=aa.sortVectors(c.data)c.save()
turtlecraft.term.clear("Add Shape")turtlecraft.term.write(1,4,"All done!")
turtlecraft.input.readKey(5)end;if(d.isEnabled())then local ab=d.get()_b(ab)end end;turtlecraft.scope()
-- File: help --
turtlecraft.help={}
turtlecraft.scope=function()
local a=function()
print("Press any key to read more...")turtlecraft.input.readKey()term.clear()
term.setCursorPos(1,1)end
local b=function(c)local d,_a=term.getSize()term.clear()
term.setCursorPos(1,1)local aa=1;local ba=""local ca=string.gmatch(c,"[^\n]+")
for da in ca do
local _b=string.gmatch(da,"%S+")
for ab in _b do local bb=ab.." "local cb=string.len(bb)local db=string.len(ba)
if(db+cb>=d-
1)then print(ba)ba=""aa=aa+1;if(aa>= (_a-1))then a()aa=1 end end;ba=ba..bb end;print(ba)ba=""aa=aa+1;if(aa>= (_a-1))then a()aa=1 end end;a()end
turtlecraft.help.general=function()
local c=
"Turtlecraft is a menu-driven system that will help you utilize your turtle for various creating, digging, and collection functions.\n"..
"Select 'Dig functions' to excavate, fill/clear areas, or 'eat'.\n"..
"Select 'Build functions' to have your turtle help you create 2d and 3d shapes.\n"..
"There is a whole world of things you can make your turtle do. Turtlecraft will only help you with these few things.\n"b(c)end
turtlecraft.help.dig=function()
local c="Excavate: This will dig directly in front of the turtle's current position. "..

"You will be able to specify how far forward, left, right, up, and down to dig. "..
"The turtle will always try to unload directly behind it's start position when it is full. "..

"It will also return to its start position for more fuel when it is empty. "..
"If the turtle is unloaded or interrupted it will attempt to resume the next time it reloads "..
"automatically.\n\n"..

"Eat: This will attempt to eat blocks starting from its current location. "..
"This will not return when out of fuel or full of inventory. You will need to find "..
"and satisfy the turtle's needs.\n"..

"WARNING: This can end up very bad if left unattended! DO NOT LEAVE UNATTENDED!\n"..
"Fill: This will attempt to fill an area using a circulating movement pattern. "..

"This must be pre-loaded with blocks to unload and the turtle will not return "..
"to reload or refuel. This will not dig or break blocks for any reason.\n"..

"WARNING: Your turtle is very likely to get stuck when filling in non-box shapes. "..
"For non-box shapes always start the turtle in a small area to work its way into a large area "..

"to avoid boxing itself in a corner. YOU MAY LOSE YOUR TURTLE. \n\n"..
"Empty: Much like 'Eat', this will attempt to empty an area, but will only eat one type of block. "..

"The block that it will eat can either be pre-loaded into slot 2 (slot 1 is for fuel and ignored) "..
"or the turtle will eat the first block that it finds above or below and then only continue to eat that type. "..

"This uses a circulating movement pattern to find blocks and should probably not be left unattended. "..
"This will not return to refuel or unload and will instead wait for you to fix whatever it needs ".."at whatever its current location.\n"..
"WARNING: This pattern may wander off. You should probably not leave this unattended."b(c)end
turtlecraft.help.build=function()
local c="Project: This is your virtual 3d 'canvas' that you are creating when adding shapes.\n"..

"Clear: This will erase all data from your project.\n"..
"Add: This will add a new shape (sphere, line, cube, etc...) to your project.\n"..

"Stats: This will calculate how many blocks and space your project requires.\n"..
"Send to monitor: This will attempt to render your current project on a monitor using ASCII art. "..

"The bigger your monitor the better you will be able to see what your project should look like "..
"when it is built.\n"..
"Start building: This will tell the turtle to start building your project. It will build from bottom "..

"to top and will not return to refuel or reload. If the turtle runs out of fuel or blocks to build with "..
"it must be given more supplies at its current position. If the turtle is unloaded or otherwise "..

"interrupted it will attempt to resume building upon reload.\n"..
"WARNING: Build recovery is not perfect, so there is still a small chance that when the turtle ".."resumes building that it could get offset a square."b(c)end end;turtlecraft.scope()
-- File: menu --
turtlecraft.menu={}
turtlecraft.menu[1]={title="Dig functions",action={}}turtlecraft.menu[1].action={}
turtlecraft.menu[1].action[1]={title="Excavate",action=turtlecraft.excavate.start}
turtlecraft.menu[1].action[2]={title="Eat Area",action=turtlecraft.seeker.eat}
turtlecraft.menu[1].action[3]={title="Fill Area",action=turtlecraft.seeker.fill}
turtlecraft.menu[1].action[4]={title="Empty Area",action=turtlecraft.seeker.unfill}
turtlecraft.menu[1].action[5]={title="Halp meh!",action=turtlecraft.help.dig}
turtlecraft.menu[2]={title="Build functions",action={}}turtlecraft.menu[2].action={}
turtlecraft.menu[2].action[1]={title="Clear project",action=turtlecraft.builder.clear}
turtlecraft.menu[2].action[2]={title="Add a shape",action=turtlecraft.builder.add}
turtlecraft.menu[2].action[3]={title="Trim project",action=turtlecraft.builder.trim}
turtlecraft.menu[2].action[4]={title="Project stats",action=turtlecraft.builder.stats}
turtlecraft.menu[2].action[5]={title="Send to monitor",action=function()
term.clear()print("Not Yet Implemented")read()end}
turtlecraft.menu[2].action[6]={title="Start building",action=turtlecraft.builder.start}
turtlecraft.menu[2].action[7]={title="Halp meh!",action=turtlecraft.help.build}
turtlecraft.menu[3]={title="Halp meh!",action=turtlecraft.help.general}
turtlecraft.scope=function()local a=turtlecraft.term;local b=1;local c={}
table.insert(c,turtlecraft.menu)local d=a.write
local _a=function()local ab=c[table.getn(c)]return ab end
local aa=function()
a.clear("Menu","** Use up/down and left/enter keys **")local ab=_a()
for bb,cb in ipairs(ab)do local db=cb.title
if(bb==b)then db=">"..db.."<"else db=" "..db end;a.scrolled(1,bb,b,db)end end
local ba=function()local ab=_a()local bb=ab[b].action;if(type(bb)=="function")then bb()else
table.insert(c,bb)end end
local ca=function()if(table.getn(c)>1)then b=1;table.remove(c)end end
local da=function()local ab=_a()if(b<table.getn(ab))then b=b+1 end end;local _b=function()if(b>1)then b=b-1 end end
if(not
turtlecraft.position.isInSync())then term.clear()
d(1,1,"The turtle's position has gotten out of sync.")
d(1,2,"If there was a function in progress it has likely been cancelled.")d(1,3,"Press any key to continue")
local ab,bb,cb,db=turtlecraft.position.get()turtlecraft.position.set(0,0,0,db)
turtlecraft.input.readKey()end
while(true)do aa()sleep(0.01)
local ab=turtlecraft.input.readKey()if(ab==28)then ba()end;if(ab==200)then _b()end;if(ab==208)then da()end;if
(ab==203)then ca()end end end;turtlecraft.scope()
