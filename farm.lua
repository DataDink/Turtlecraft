if (not turtle) then error("farm requires a turtle") end

os.loadAPI('turtle.crop.api')

local recover = 'farm.time'
local timer = arg and tonumber(arg[1]) or 10
local drop = arg and arg[2] == "down" and turtle.dropDown or turtle.dropUp

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Farm checks for crops in the spaces around it.")
  print("Mature crops are harvested & replanted and the yield is ejected up or down.")
  print("farm [<interval:number> [<eject:up/down>]]")
  print("")
  print(message)
end
display("")

function rest()
  local remaining = timer
  if (fs.exists(recover)) then
    local file = fs.open(recover, 'r')
    remaining = tonumber(file.readAll() or timer)
    file.close()
  end
  while (remaining > 0) do
    --display("Resting: " .. remaining)
    os.sleep(math.min(remaining, 1))
    remaining = remaining - 1
    local file = fs.open(recover, 'w')
    file.write(remaining)
    file.close()
  end
  fs.delete(recover)
end

function sort()
  for i = 16,1,-1 do
    for j = 1,i do
      if (turtle.getItemCount(j) > 0) then
        turtle.select(j)
        turtle.transferTo(i)
      end
    end
    local stack = turtle.getItemCount(i)
    if (stack > 1) then
      turtle.select(i)
      drop(stack - 1)
    end
  end
  for i = 1,4 do
    if (turtle.getItemCount(i) > 0) then return false end
  end
  return true
end

function harvest()
  turtle.select(1)
  local harvested, reason = turtle.dig()
  if (not harvested) then return false, reason end
  os.sleep(1)
  turtle.suck()
  return true
end

function replant(name)
  for _,search in pairs({name,"seed",""}) do
    for i = 1,16 do
      local _, detail = turtle.getItemDetail(i)
      if (detail and string.find(detail.name, search) 
          and turtle.select(i) 
          and turtle.place()
        ) then return true end
    end
  end
  return false
end

while (true) do
  while (not sort()) do
    display("Additional space required")
    os.sleep(10)
  end
  rest()
  local _, inspection = turtle.inspect()
  local name = inspection and inspection.name
  local mature, reason = turtle.crop.mature()
  display("Inpsection: " .. tostring(mature) .. "/" .. tostring(name))
  if (mature) then
    local harvested, reason = harvest()
    if (not harvested) then
      display("Harvest Failed: " .. tostring(reason))
    end
    local replanted = harvested and replant(name)
    if (not replanted) then
      display("Replant Failed")
    end
  end
  turtle.turnRight()
end

