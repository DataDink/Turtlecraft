if (not turtle) then error("Error: Drop requires a turtle") end

local PLACE = arg and tostring(arg[1]) or 'front'
local PULL = arg and string.lower(tostring(arg[2])) ~= 'false'
local RSTONE = arg and string.lower(tostring(arg[3])) ~= 'false'

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Place will place blocks either above, below or in front of the turtle.")
  print('It will optionally pull from an inventory and/or wait for a redstone signal.')
  print('place [<place:up/down/front> [<pull:true/false> [<redstone:true/false>]]]')
  print('')
  print(message)
end

function signal()
  for _, side in pairs(redstone.getSides()) do
    if (redstone.getInput(side)) then
      return true
    end
  end
  return false
end

function inventory()
  for i = 1, 16 do
    if (turtle.getItemCount(i) > 0) then
      return i
    end
  end
  if (not PULL) then return false end
  for side in pairs({"top", "bottom", "front"}) do
    local _, type = peripheral.getType(side)
    if (type == "inventory") then
      if (#peripheral.call(side, "list") > 0) then
        return side
      end
    end
  end
  return false
end

function wait()
  while (RSTONE and not signal()) do pullEvent("redstone") end
  local items = inventory()
  while (items == false) do
    os.sleep(1)
    items = inventory()
  end
  return items
end

function place(from)
  if (type(from) == "number") then
    turtle.select(from)
  elseif (from == "top") then
    turtle.suckUp()
  elseif (from == "bottom") then
    turtle.suckDown()
  elseif (from == "front") then
    turtle.suck()
  end
  if (PLACE == "up") then return turtle.placeUp()
  elseif (PLACE == "down") then return turtle.placeDown()
  return turtle.place()
end

while (true) do
  display("Waiting...")
  local items = wait()
  display("Placing...")
  place(items)
  os.sleep(0.1)
end
