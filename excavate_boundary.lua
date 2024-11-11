if (not turtle) then error("excavate_boundary requires a turtle") end

os.loadAPI('turtle.track.api')
os.loadAPI('turtle.boundary.api')
turtle.select(1)

local resuming = arg and arg[1] == "resume"
if (not resuming) then
  turtle.track.clear()
  shell.run('recover excavate_boundary resume')
end

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Excavates a rectangular boundary.")
  print("Attempts to recover when reloaded.")
  print("Requires fuel in slot #1")
  print("")
  print(message)
end
message("")

function refuel(req)
  if (turtle.getFuelLevel() > req) then return true end
  while (turtle.getFuelLevel() < req) do
    if (turtle.getItemCount(1) < 2 or not turtle.refuel(1)) then
      message("Refueling: need more fuel in slot 1")
      os.sleep(1)
    end
  end
end

function surface()
  if (turtle.track.get() == 0) then return true end
  local move = turtle.track.get() > 0 and turtle.track.down or turtle.track.up
  while (turtle.track.get() ~= 0) do
    refuel(1)
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
  while (not turtle.detectDown() or turtle.digDown() or not turtle.detectDown() or turtle.attackDown()) do
    turtle.track.down()
  end
  surface()
end

while (true) do
  while (full()) do
    surface()
    message("Inventory: awaiting unload")
    os.sleep(1)
  end
  dig()
  turtle.boundary.next()
end
