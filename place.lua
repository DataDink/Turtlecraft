if (arg and arg[1] == "help") then
  print("Usage: [recover] place [<restrict> [<redstone>]]")
  print("* restrict: up/down/front")
  print("    restricts placing to the specified side.")
  print("* redstone: true/false")
  print("    whether to wait for a redstone pulse.")
  return
end

if (not turtle) then error("Error: Drop requires a turtle") end

local RESTRICT = arg and string.lower(tostring(arg[1]))
local REDSTONE = arg and string.lower(tostring(arg[2])) == 'true'

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Place will place blocks above, in front, and below.")
  print("It will pull items from chests above, in front, and below it.")
  print("It will optionally wait for a redstone signal.")
  print("(see `place help` for usage)")
  print('')
  print(message)
end

function isRestricted(side)
  if (RESTRICT == side) then return false end
  if (RESTRICT ~= "up" and RESTRICT ~= "down" and RESTRICT ~= "front") then return false end
  return true
end

function isInventory(side)
  local _, type = peripheral.getType(side)
  return type == "inventory"
end

function isSignal()
  for _, side in pairs(redstone.getSides()) do
    if (redstone.getInput(side)) then return true end
  end
  return false
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

function refill()
  for _, side in pairs({
    {isInventory("top"), turtle.suckUp}, 
    {isInventory("bottom"), turtle.suckDown}, 
    {isInventory("front"), turtle.suck}
  }) do
    if (side[1]) then
      while (side[2]()) do os.sleep(0.1) end
    end
  end
end

function place()
  for _, side in pairs({
    {isRestricted("up"), turtle.detectUp(), turtle.placeUp},
    {isRestricted("down"), turtle.detectDown(), turtle.placeDown},
    {isRestricted("front"), turtle.detect(), turtle.place}
  }) do
    if (side[1] and not side[2]) then
      refill()
      for i = 1, 16 do
        if (turtle.getItemCount(i) > 0) then
          turtle.select(i)
          if (side[3]()) then break end
        end
      end
    end
  end
end

display("")
while (true) do
  wait()
  place()
end

