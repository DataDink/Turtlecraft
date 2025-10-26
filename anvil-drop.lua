if (arg and arg[1] == "help") then
  print("Usage: [recover] anvil-drop")
  print("Setup:")
  print("1. Place a `anvil-drop` turtle on top.")
  print("2. Place a chest/inventory below.")
  print("3. Place a `break.lua` turtle on bottom.")
  print("4. Leave a space in front to drop items.")
  return
end

if (not turtle) then error("Error: anvil-drop requires a turtle") end

function waitKey()
  local _,key = os.pullEvent("key")
  return key
end

function waitEnter()
  while waitKey() ~= keys.enter do end
end

function instruct()
  term.clear()
  term.setCursorPos(1, 1)
  print("** Anvil Drop Instructions **")
  print()
  print("* Place anvil in inventory.")
  print("* Place recipe items in inventory.")
  print("(see `break help` for setup)")
  print()
  print("Press enter to start...")
  waitEnter()
end

function dialog(message)
  term.clear()
  term.setCursorPos(1, 1)
  print("** Anvil Drop Message **")
  print()
  print(message)
  print()
  os.sleep(3)
end

function isAnvil(name)
  return name == "minecraft:anvil" or name == "minecraft:chipped_anvil" or name == "minecraft:damaged_anvil"
end

function inspect()
  if (turtle.detect()) then
    dialog("There should be 1 empty space in front.")
    return false
  end
  local _, below = peripheral.getType("bottom")
  if (below ~= "inventory") then
    dialog("Missing chest below.")
    return false
  end
  local hasAnvil = false
  local hasItems = false
  for i = 1, 16 do
    local info = turtle.getItemDetail(i)
    if (info and isAnvil(info.name)) then hasAnvil = true
    elseif (info and info.count > 0) then hasItems = true end
  end
  local items = peripheral.call("bottom", "list")
  for _, item in pairs(items) do
    if (isAnvil(item.name)) then hasAnvil = true
    elseif (item.count > 0) then hasItems = true end
  end
  if (not hasAnvil) then
    dialog("Missing anvil.")
    return false;
  end
  if (not hasItems) then
    dialog("Missing items.")
    return false;
  end
  return true
end

function refill()
  while (turtle.suckDown()) do
    os.sleep(0.1)
  end
end

function drop()
  refill()
  for i = 1, 16 do
    local info = turtle.getItemDetail(i)
    if (info and not isAnvil(info.name)) then
      turtle.select(i)
      turtle.drop()
    end
  end
  os.sleep(1)
  for i = 1, 16 do
    local info = turtle.getItemDetail(i)
    if (info and isAnvil(info.name)) then
      turtle.select(i)
      turtle.place()
      return true
    end
  end
  dialog("Drop anvil failed.")
  return false
end

function emit()
  for _, side in pairs(redstone.getSides()) do
    redstone.setOutput(side, true)
  end
  os.sleep(1)
  for _, side in pairs(redstone.getSides()) do
    redstone.setOutput(side, false)
  end
end

while (true) do
  instruct()
  if (inspect() and drop()) then 
    emit()
    dialog("One more moment...")
    refill()
  end
end
