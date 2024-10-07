if (not turtle) then error("farm requires a turtle") end

os.loadAPI('turtle.crop.api')

local timer = args and args[1] or 10
local direction = args and args[2] == "down" or false

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Farm checks for crops in the spaces around it.")
  print("When a crop is mature it will be harvested then replanted and the remaining items are ejected upwards.")
  print("farm [<timeout:number> [<direction:up/down>]]")
  print("")
  print(message)
end

while (true) do
  local mature, reason = turtle.crop.mature()
  display("Inspecting: " .. tostring(mature) .. "/" .. tostring(reason))
  if (mature) then turtle.dig() end
  if (not turtle.detect()) then
    for i = 1,16 do
      if (turtle.getItemCount(i) > 0 and turtle.select(i)) then
        local placed, reason = turtle.place()
        if (not placed and reason) then display("Failed to plant: " .. tostring(reason)) end
      end
    end
  end
  for i = 1,16 do
    if (turtle.getItemCount(i) > 0 and turtle.select(i)) then 
      if (direction) then turtle.dropDown() else turtle.dropUp() end
    end
  end
  os.sleep(timer)
  turtle.turnRight()
end
