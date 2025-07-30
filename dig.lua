if (not turtle) then error("dig requires a turtle") end

os.loadAPI('turtle.track.api')
os.loadAPI('turtle.boundary.api')
turtle.select(1)

local resuming = arg and arg[1] == "recover"
if (not resuming) then
  turtle.track.clear()
end
if (not resuming and fs.exists('startup.lua')) then
  shell.run('recover dig recover')
end

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Excavates to a rectangular boundary.")
  print("Requires fuel in slot #1")
  print("")
  print(message)
end

function ask()
  local result = false
  parallel.waitForAny(
    function() 
      for i = 5,0,-1 do
        display("Hold down ENTER to quit: " .. tostring(i))
        os.sleep(1)
      end
      display("Continuing...")
      result = true
    end,
    function() 
      local key = nil
      while (key ~= keys.enter) do
        _, key = os.pullEvent('key')
      end
      fs.delete('startup.lua')
      display("Exiting...")
      result = false
    end
  )
  return result
end

function refuel(req)
  if (turtle.getFuelLevel() > req) then return true end
  while (turtle.getFuelLevel() < req) do
    if (turtle.getItemCount(1) < 2 or not turtle.refuel(1)) then
      display("Refueling: need more fuel in slot 1")
      os.sleep(1)
    end
    display("Continuing...")
  end
end

function surface()
  if (turtle.track.get() == 0) then return true end
  local move = turtle.track.get() > 0 and turtle.track.down or turtle.track.up
  while (turtle.track.get() ~= 0) do
    move()
  end  
end

function full()
  for i = 2,16 do
    if (turtle.getItemCount(i) == 0) then return false end
  end
  return true
end

function dig()
  refuel(256)
  while (not turtle.detectDown() or turtle.digDown() or not turtle.detectDown() or turtle.attackDown()) do
    turtle.track.down()
  end
  surface()
end

while (true) do
  while (full()) do
    surface()
    display("Inventory: awaiting unload")
    os.sleep(1)
  end
  if (not ask()) then return end
  dig()
  turtle.boundary.next()
end
