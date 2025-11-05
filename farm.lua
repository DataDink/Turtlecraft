if (arg and arg[1] == "help") then
  print("Usage: [recover] farm [<interval> [<replant>]]")
  print("* interval: number")
  print("    how often to check crops.")
  print("* replant: yes/no")
  print("    whether to replant crops.")
  return
end

if (not turtle) then error("farm requires a turtle") end

os.loadAPI('turtle.crop.api')

local recover = 'farm.time'
local timer = arg and tonumber(arg[1]) or 10
local doplant = not arg or arg[2] ~= "no"

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Farm checks for crops in the spaces around it.")
  print("Mature crops are harvested & replanted and the yield is ejected up or down.")
  print("(see `farm help` for usage)")
  print("")
  print(message)
end
display("")

function isFull()
  local space = 0
  for i = 1,16 do
    if (turtle.getItemCount(i) == 0) then
      space = space + 1
    end
  end
  return space < 4
end

function isRedstone()
  for _, side in pairs(redstone.getSides()) do
    if (redstone.getInput(side)) then return true end
  end
  return false
end

function getInventories()
  local inventories = {}
  local _, up = peripheral.getType("top")
  if (up == 'inventory') then table.insert(inventories, turtle.dropUp) end
  local _, down = peripheral.getType("bottom")
  if (down == 'inventory') then table.insert(inventories, turtle.dropDown) end
  return inventories
end

function rest()
  local remaining = timer
  if (fs.exists(recover)) then
    local file = fs.open(recover, 'r')
    remaining = tonumber(file.readAll() or timer)
    file.close()
  end
  while (remaining > 0) do
    os.sleep(1)
    remaining = remaining - 1
    local file = fs.open(recover, 'w')
    file.write(remaining)
    file.close()
  end
  fs.delete(recover)
  return true
end

function cleanup()
  local inventories = getInventories()
  if (#inventories) then
    for i = 1,16 do
      if (turtle.getItemCount(i) > 1) then
        turtle.select(i)
        for _, inv in pairs(inventories) do
          local excess = turtle.getItemCount(i) - 1
          if (excess > 0) then inv(excess) end
        end
      end
    end
  end
  for i = 2,16 do
    if (turtle.getItemCount(i) > 0) then
      for j = 1,i-1 do
        if (turtle.getItemCount(i) > 0) then
          turtle.select(i)
          turtle.transferTo(j)
        end
      end
    end
  end
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
  if (not doplant) then return true end
  local search = {name}
  for word in string.gmatch(name, "%w+") do
    table.insert(search, word)
  end
  table.insert(search, "")
  for _, value in pairs(search) do
    for i = 1,16 do
      local detail = turtle.getItemDetail(i)
      if (detail and string.find(detail.name, value) 
          and turtle.select(i) 
          and turtle.place()
        ) then return true end
    end
  end
  return false
end

while (true) do
  cleanup()
  rest()
  while (isFull()) do
    display("Additional space required")
    os.sleep(3)
  end
  while (isRedstone()) do
    display("Redstone signal detected, waiting...")
    os.sleep(0.1)
  end
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

