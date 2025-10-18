if (not turtle) then error("Error: Drop requires a turtle") end

local direction = arg and tostring(arg[1]) or 'front'
local rstone = arg and tostring(arg[2]) == 'false'

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Place will place blocks either above, below or in front of the turtle.")
  print('It will optionally wait for a redstone signal.')
  print('place [<direction:up/down/front> [<redstone:true/false>]]')
  print('')
  print(message)
end

function locate()
  for i = 1, 16 do
    if (turtle.getItemCount(i) > 0) then return i end
  end
end

function wait()
  while (true) do
    if (rstone) then
      os.pullEvent("redstone")
      for _, side in pairs(redstone.getSides()) do
        if (redstone.getInput(side)) then return end
      end
    else
      if (locate()) then return end
      os.sleep(1)
    end
  end
end

function place()
  local slot = locate()
  turtle.select(slot)
  if (direction == 'up') then return turtle.placeUp() end
  if (direction == 'down') then return turtle.placeDown() end
  return turtle.place()
end

while (true) do
  display("")
  wait()
  place()
end
