local cfgjson = "{\"minify\":true,\"maxDigs\":300,\"maxMoves\":10,\"maxAttacks\":64,\"recoveryPath\":\"turtlecraft/recovery/\",\"version\":\"2.0.0\",\"pastebin\":\"kLMahbgd\",\"build\":\"1509103674203\"}";
TurtleCraft={}(function()local a={}TurtleCraft.export=function(b,c)local d=type(c)~='function'a[b]={resolved=d,value=c}end;TurtleCraft.import=function(b)if a[b]then error('module '..b..' does not exist.')end;if not a[b].resolved then a[b].value=a[b].value()end;return a[b].value end end)()
TurtleCraft.export('services/config',function()return TurtleCraft.require('services/json').parse(cfgjson or'{}')end)
TurtleCraft.export('services/io',function()local a={}a.readKey=function(b)if b then os.startTimer(b)end;local c,d,e;repeat c,d,e=os.pullEvent()until c=="key"or c=="timer"if c=="timer"then return false,false end;return d,e end;a.setCancelKey=function(d,f)parallel.waitForAny(f,function()local g;repeat _,g=os.pullEvent('key')until g==d end)end;a.centerLine=function(h,i,j)if j==nil then _,j=term.getCursorPos()end;local k=term.getSize()local l=math.floor(k/2-h:len()/2)if l<0 then term.setCursorPos(1,j)term.write(h:sub(math.abs(l)+1,l-1))return end;if i~=nil then term.setCursorPos(1,j)term.write(i:rep(k))end;term.setCursorPos(l,j)term.write(h)end;a.centerPage=function(h,i)local m={}for j in h:gsub('[^\n]+')do table.insert(m,j)end;local n=#m;local _,o=term.getSize()local p=math.floor(o/2-n/2)for q=1,n do a.centerLine(m[q],i,p+q)end end end)
TurtleCraft.export('services/json',function()local a={}a.trim=function(b)return b:gsub('^%s|%s$')end;a.parseNull=function(b)b=a.trim(b)if not b:gmatch('^null')()then return false,b:len()end;b=b:sub(4)return true,nil,b end;a.parseNumber=function(b)b=a.trim(b)local c=b:gmatch('^-?%d+|^-?%d+%.%d+')()if c==nil then return false,b:len()end;b=b:sub(c:len()+1)return true,tonumber(c),b end;a.parseBoolean=function(b)b=a.trim(b)local c=b:lower():gmatch('^true|^false')()if c==nil then return false,b:len()end;b=b:sub(c:len()+1)return true,c=='true',b end;a.parseString=function(b)b=a.trim(b)if b:sub(1,1)~='"'then return false,b:len()end;b=b:sub(2)local c=''local d=b:gmatch('[^\\"]*[\\"]')()while d~=nil do b=b:sub(d:len()+1)if d:sub(-1)=='"'then c=c..d:sub(1,-2)return true,c,b end;c=c..d:sub(1,-2)local e=b:sub(1,1)b=b:sub(2)if e=='"'then c=c..'"'end;if e=='\\'then c=c..'\\'end;if e=='/'then c=c..'/'end;if e=='b'then c=c..'\b'end;if e=='f'then c=c..'\f'end;if e=='n'then c=c..'\n'end;if e=='r'then c=c..'\r'end;if e=='t'then c=c..'\t'end;if e=='u'then local f=tonumber(b:sub(1,4),16)%256;b=b:sub(5)c=c..string.char(f)end;d=b:gmatch('[^\\"]*[\\"]')()end;return false,b:len()end;a.parseArray=function(b)b=a.trim(b)if b:sub(1,1)~='['then return false,b:len()end;b=b:sub(2)local g={}local h,c,b=a.parseNext(b)while h do table.insert(g,c)b=a.trim(b)local i=b:sub(1,1)b=b:sub(2)if i==']'then return true,g,b end;if i~=','then return false,b:len()end;h,c,b=a.parseNext(b)end;return false,b:len()end;a.parseObject=function(b)b=a.trim(b)if b:sub(1,1)~='{'then return false,b:len()end;b=b:sub(2)local g={}local h,j,b=a.parseString(b)while h do b=a.trim(b)if b:sub(1,1)~=':'then return false,b:len()end;b=b:sub(2)local k,c,b=a.parseNext(b)if not k then return false end;g[j]=c;b=a.trim(b)local i=b:sub(1,1)b=b:sub(2)if i=='}'then return true,g,b end;if i~=','then return false,b:len()end;h,j,b=a.parseString(b)end;return false,b:len()end;a.parseNext=function(b)for l,m in ipairs({a.parseNull,a.parseNumber,a.parseBoolean,a.parseString,a.parseArray,a.parseObject})do local n,c,b=m(b)if n then return true,c,b end end;return false,b:len()end;a.parse=function(b)local n,c=a.parseNext(b)if n then return c else return nil end end;a.format=function(c)if type(c)=='nil'then return'null'end;if type(c)=='boolean'then return tostring(c)end;if type(c)=='number'then return tostring(c)end;if type(c)=='string'then c=c:gsub('\\','\\\\')c=c:gsub('\"','\\"')c=c:gsub('\/','\\/')c=c:gsub('\b','\\b')c=c:gsub('\f','\\f')c=c:gsub('\n','\\n')c=c:gsub('\r','\\r')c=c:gsub('\t','\\t')return'"'..c..'"'end;if type(c)=='table'and#c then local o={}for l,p in ipairs(c)do table.insert(o,a.format(p))end;return'['..table.concat(o,',')..']'end;if type(c)=='table'then local o={}for q,r in pairs(c)do table.insert(o,'"'..q..'":'..a.format(r))end;return'{'..table.concat(o,',')..'}'end end;return a end)
TurtleCraft.export('services/recovery',function()local a=TurtleCraft.require('config')local b=TurtleCraft.require('services/io')local c={x=0,y=0,z=0,f=0}local d=a.recoveryPath..'position.dat'local e=fs.open(d,'a')local f=a.recoveryPath..'tasks.dat'local g={}local h={}local i={location={},face=function(j)j=j%4;if j==c.facing then return true end;local k=j>c.facing and turtle.turnRight or turtle.turnLeft;local l=math.abs(j-c.facing)if l>2 then l=1;k=k==turtle.turnRight and turtle.turnLeft or turtle.turnRight end;local m=k==turtle.turnRight and'right'or'left'for n=0,l do k()e.writeLine(m)e.flush()if k==turtle.turnRight then c.facing=c.facing+1 end;if k==turtle.turnLeft then c.facing=c.facing-1 end end;return true end,moveTo=function(o,p,q)return h.navigateTo('moveTo',h.moveForward,h.moveUp,h.moveDown,o,p,q)end,digTo=function(o,p,q)return h.navigateTo('digTo',h.digForward,h.digUp,h.digDown,o,p,q)end,excavateTo=function(o,p,q)return h.navigateTo('excavateTo',h.excavateForward,h.excavateUp,h.excavateDown,o,p,q)end,start=function(r)local s=fs.open(f,'a')s.writeLine(r)s.close()table.insert(g,r)end,finish=function()local s=fs.open(f,'a')s.writeLine('end')s.close()table.remove(g)local t=h.readTasks()if#t==0 then fs.open(f,'w').close()local u='location '..c.x..' '..c.y..' '..c.z..' '..c.f;e.close()e=fs.open(d,'w')e.writeLine(u)end end,recover=function()TurtleCraft.require('views/notification').show('Recovering...\nPress ESC to cancel')local v=b.readKey(60)if v==keys.esc then return end;TurtleCraft.require('views/notification').show('Recovering\nLast Session')h.recoverPosition()h.recoverTasks()end,reset=function()fs.open(f,'w')g={}e=fs.open(d,'w')c={x=0,y=0,z=0,f=0}end}setmetatable(i.location,{__index=c,__newindex=function()return end})h.processForward=function()if c.facing==0 then c.y=c.y+1 end;if c.facing==1 then c.x=c.x+1 end;if c.facing==2 then c.y=c.y-1 end;if c.facing==3 then c.x=c.x-1 end end;h.processDown=function()c.z=c.z-1 end;h.processUp=function()c.z=c.z+1 end;h.processRight=function()c.f=(c.f+1)%4 end;h.processLeft=function()c.f=(c.f-1)%4 end;h.readTasks=function()if not fs.exists(f)then return{}end;local w={}local s=fs.open(f,'r')local x=s.readLine()while x do if x=='end'then table.remove(w)else table.insert(w,x)end;local x=s.readLine()end;s.close()return w end;h.recoverPosition=function()if not fs.exists(d)then return end;local y=fs.open(a.recoveryPath,'r')local z=y.readLine()while z do if z=='forward'then h.processForward()end;if z=='up'then h.processUp()end;if z=='down'then h.processDown()end;if z=='left'then h.processLeft()end;if z=='right'then h.processRight()end;if z:match('^location %d+ %d+ %d+ %d$')then local A=z:gmatch('%d+')c.x=tonumber(A())c.y=tonumber(A())c.z=tonumber(A())c.f=tonumber(A())end;z=y.readLine()end;y.close()e=fs.open(d,'w')e.writeLine('location '..e.x..' '..e.y..' '..e.z..' '..e.f)end;h.recoverTasks=function()if not fs.exists(f)then return end;local B=h.readTasks()local s=fs.open(f,'w')for C,D in ipairs(B)do s.writeLine(D)end;s.close()for C,D in ipairs(B)do h.exec(D)end end;h.exec=function(z)local E=z:gsub('[^%s]+')local F=E()local k=E()local A={}local G=E()while G do if G:match('^%d+%.%d+$|^%d+$')then G=tonumber(G)end;if G:upper()=='TRUE'then G=true end;if G:upper()=='FALSE'then G=false end;table.insert(A,G)G=E()end;local H=TurtleCraft.require(F)local I=H[k]I(table.unpack(A))end;h.moveForward=function()return h.retry(function()if turtle.forward()then e.writeLine('forward')e.flush()h.processForward()return true end;return false end,a.maxMoves)end;h.moveUp=function()return h.retry(function()if turtle.up()then e.writeLine('up')e.flush()h.processUp()return true end;return false end,a.maxMoves)end;h.moveDown=function()return h.retry(function()if turtle.down()then e.writeLine('down')e.flush()h.processDown()return true end;return false end,a.maxMoves)end;h.digDetect=function(J,K)return h.retry(function()if not K()then return true end;J()return not K()end,a.maxDigs)end;h.digMove=function(K,J,L,M)return h.retry(function()if not h.digDetect(K,J)then return false end;L()return M()end,a.maxAttacks)end;h.digForward=function()return h.digMove(turtle.detect,turtle.dig,turtle.attack,function()if turtle.forward()then e.writeLine('forward')e.flush()h.processForward()return true end;return false end)end;h.digUp=function()return h.digMove(turtle.detectUp,turtle.digUp,turtle.attackUp,function()if turtle.up()then e.writeLine('up')e.flush()h.processUp()return true end;return false end)end;h.digDown=function()return h.digMove(turtle.detectDown,turtle.digDown,turtle.attackDown,function()if turtle.down()then e.writeLine('down')e.flush()h.processDown()return true end;return false end)end;h.excavateForward=function()h.digDetect(turtle.detectUp,turtle.digUp)h.digDetect(turtle.detectDown,turtle.digDown)return h.digForward()end;h.excavateUp=function()h.digDetect(turtle.detect,turtle.dig)return h.digUp()end;h.excavateDown=function()h.digDetect(turtle.detect,turtle.dig)return h.digDown()end;h.retry=function(k,N)for O=0,N do if k()then return true end end;return false end;h.navigateTo=function(P,Q,R,S,o,p,q)i.start('services/recovery '..P..' '..o..' '..p..' '..q)for n=0,n<3 do while c.x<o do i.face(1)if not Q()then break end end;while c.x>o do i.face(3)if not Q()then break end end;while c.y<p do i.face(0)if not Q()then break end end;while c.y>p do i.face(2)if not Q()then break end end;while c.z<q do if not R()then break end end;while c.z>q do if not S()then break end end end;i.finish()return c.x==o and c.y==p and c.z==q end;return i end)
TurtleCraft.export('views/border',function()local a=TurtleCraft.require('config')local b=TurtleCraft.require('services/io')return{show=function()b.printCentered('TurtleCraft v'..a.version)end}end)
TurtleCraft.export('views/notification',function()end)
(function()local a=TurtleCraft.require('services/io')a.centerLine('test')a.readKey()a.centerPage('test')a.readKey()end)()