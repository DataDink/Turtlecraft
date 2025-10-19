if (not turtle) then error("Error: Drop requires a turtle") end

local RESTRICT = arg and string.lower(tostring(arg[1]))
local REDSTONE = arg and string.lower(tostring(arg[2])) == 'true'

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Break will break blocks above, below or in front of it.")
  print("It will push items into chests above, below or in front of it.")
  print("It will optionally wait for a redstone signal.")
  print("break [<restrict:up/down/front> [<redstone:true/false>]]")
  print('')
  print(message)
end

function isRestricted(side)
  if (RESTRICT == side) then return false end
  if (RESTRICT ~= "up" and RESTRICT ~= "down" and RESTRICT ~= "front") then return false end
  return true
end

function isSignal()
  for _, side in pairs(redstone.getSides()) do
    if (redstone.getInput(side)) then return true end
  end
  return false
end

function isInventory(side)
  local _, type = peripheral.getType(side)
  return type == "inventory"
end

function wait()
  while (true) do
    if (REDSTONE) then os.pullEvent("redstone") else os.sleep(0.5) end
    while (REDSTONE and not isSignal()) do os.pullEvent("redstone") end
    if (not isRestricted("up") and not turtle.detectUp()) then return end
    if (not isRestricted("down") and not turtle.detectDown()) then return end
    if (not isRestricted("front") and not turtle.detect()) then return end
  end
end

function dig()
  if (not isRestricted("up") and not isInventory("top") and turtle.detectUp()) then return turtle.digUp end
  if (not isRestricted("down") and not isInventory("bottom") and turtle.detectDown()) then return turtle.digDown end
  if (not isRestricted("front") and not isInventory("front") and turtle.detect()) then return turtle.dig end
end

function collect()
  os.sleep(1)
  if (not turtle.detectUp()) then turtle.suckUp() end
  if (not turtle.detectDown()) then turtle.suckDown() end
  if (not turtle.detect()) then turtle.suck() end
  for i = 1, 16 do
    if (turtle.getItemCount(i) > 0) then
      turtle.select(i)
      if (isInventory("top")) then turtle.dropUp() end
      if (isInventory("bottom")) then turtle.dropDown() end
      if (isInventory("front")) then turtle.drop() end
    end
  end
end

display()
while (true) do
  wait()
  dig()
  collect()
end

