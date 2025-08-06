if (not turtle) then error("farm requires a turtle") end

local timer = arg and tonumber(arg[1]) or 10


function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("TreeFarm checks for logs in the spaces around it and plants saplings.")
  print("Reserve slots with saplings and logs.")
  print("For small, straight trees only.")
  print("treefarm [<interval:number>]")
  print("")
  print(message)
end
display("")

function identify(name)
  if (not name) then return end
  if (name:sub(-#"_sapling") == "_sapling") then return "sapling" end
  if (name:sub(-#"_log") == "_log") then return "log" end
  if (name:sub(-#"_leaves") == "_leaves") then return "leaves" end
end

function identifySlot(slot)
  local detail = turtle.getItemDetail(slot)
  return detail and identify(detail.name)
end

function identifyBlock(inspect)
  local _, info = inspect()
  return info and identify(info.name)
end

function identifyUp() return identifyBlock(turtle.inspectUp) end
function identifyFront() return identifyBlock(turtle.inspect) end
function identifyDown() return identifyBlock(turtle.inspectDown) end

function refuel()
  while (turtle.getFuelLevel() < 50) do
    display("Consuming logs for fuel...")
    for i = 1,16 do
      while (turtle.getFuelLevel() < 50 and turtle.getItemCount(i) > 1 and identifySlot(i) == "log") then
        turtle.select(i)
        turtle.refuel(1)
      end
    end
  end
  display("")
end

function floor()
  display("Returning to ground level...")
  while (true) do
    if (identifyDown()) then turtle.digDown() end
    if (turtle.detectDown()) then return end
    turtle.down()
  end
  display("")
end

function chop()
  display("Chopping logs and leaves...")
  while (true) do
    local up = turtle.detectUp()
    if (up) then turtle.digUp() end
    local front = turtle.detect()
    if (front) then turtle.dig() end
    if (not up and not front) then break end
    turtle.up()
  end
  floor()
end

function gather()
  display("Gathering adjacent drops...")
  for i = 1,4 do
    turtle.suck()
    turtle.turnLeft()
  end
end

function plant()
  display("Planting a sapling...")
  while (true) do
    for i = 1,16 do
      if (identifySlot(i) == "sapling" and turtle.getItemCount(i) > 1) then
        turtle.select(i)
        if (turtle.place()) then return display("") end
      end
    end
    os.sleep(1)
  end
end

turtle.up() -- If resuming, check to see if there is unfinished tree above
if (turtle.detectUp() or turtle.detect()) then chop() end
floor()

while (true) do
  if (not turtle.inspect()) then plant() end
  if (identifyFront() ~= "sapling") then 
    refuel()
    chop()
    gather()
    plant()
  end
  os.sleep(timer)
  turtle.turnRight()
end
