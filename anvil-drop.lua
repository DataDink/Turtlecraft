if (not turtle) then error("Error: Drop requires a turtle") end

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
  print("* Place inventory below turtle.")
  print("* Place wall 1 space in front.")
  print("* Place anvil in the inventory.")
  print("* Place items in the inventory.")
  print("* After drop, turtle emits redstone.")
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

function inventory()
  local _,type = peripheral.getType("bottom")
  if (type ~= 'inventory') then return false end
  local items = {}
  for _, item in pairs(peripheral.call("bottom", "list")) do 
    table.insert(items, item) 
  end
  return items
end

function inspect()
  if (turtle.detect()) then
    dialog("There should be 1 empty space in front.")
    return false
  end
  local items = inventory()
  if (not items) then
    dialog("Missing chest below.")
    return false
  end
  local hasAnvil = false
  local hasItems = false
  for _, item in pairs(items) do
    if (item.name == "minecraft:anvil" or item.name == "minecraft:chipped_anvil" or item.name == "minecraft:damaged_anvil") then
      hasAnvil = true
    elseif (item.count > 0) then
      hasItems = true
    end
  end
  if (not hasAnvil) then
    dialog("Missing anvil in chest.")
    return false;
  end
  if (not hasItems) then
    dialog("Missing items in chest.")
    return false;
  end
  return true
end

function suck()
  while (#inventory() > 0 and turtle.suckDown()) do 
    os.sleep(0.1)
  end
  if (#inventory() > 0) then
    dialog("Empty chest failed.")
    return false
  end
  return true
end

function drop()
  for i = 1, 16 do
    local info = turtle.getItemDetail(i)
    if (info and info.name ~= "minecraft:anvil" and info.name ~= "minecraft:chipped_anvil" and info.name ~= "minecraft:damaged_anvil") then
      turtle.select(i)
      turtle.drop()
    end
  end
  for i = 1, 16 do
    local info = turtle.getItemDetail(i)
    if (info and (info.name == "minecraft:anvil" or info.name == "minecraft:chipped_anvil" or info.name == "minecraft:damaged_anvil")) then
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
  if (inspect() and suck() and drop()) then 
    emit() 
  end
end
