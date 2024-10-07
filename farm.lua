os.loadAPI('turtle.crop.api')

local timer = args and args[1] or 10
local direction = args and args[2] == "down" or false

while (true) do
  if (turtle.crop.mature()) then turtle.dig() end
  if (not turtle.detect()) then
    for i = 1,16 do
      if (turtle.getItemCount(i) > 0 and turtle.select(i) and turtle.place()) then break end
    end
  end
  for i = 1,16 do
    if (turtle.getItemCount(i) > 0 and turtle.select(i)) then 
      if (direction) then turtle.dropDown() else turtle.dropUp() end
    end
  end
  os.sleep(timer)
end
