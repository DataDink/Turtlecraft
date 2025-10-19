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
  print("* Place turtle with inventory below it.")
  print("* Place wall 1 space in front of both.")
  print("* Place anvil and items in the inventory.")
  print("* After completion the turtle emits redstone.")
  print()
  print("Press enter to start...")
  waitEnter()
end

function complain(message)
  term.clear()
  term.setCursorPos(1, 1)
  print("** Anvil Drop Fixes **")
  print()
  print(message)
  print()
  os.sleep(3)
end

function inspect()
  if (turtle.detect()) then
    complain("There should be 1 empty space in front.")
    return false
  end
  local _, bottom = peripheral.getType("bottom")
  if (not bottom or bottom ~= "inventory") then
    complain("The inventory should be below the turtle.")
    return false
  end
  local inventory = peripheral.wrap("bottom")
  local items = inventory.list()
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
    complain("The anvil should be in the inventory.")
    return false;
  end
  if (not hasItems) then
    complain("The items should be in the inventory.")
    return false;
  end
  return true
end

function suck()
  local inventory = peripheral.wrap("bottom")
  while (#inventory.list() > 0 and turtle.suckDown()) do end
  if (#inventory.list() > 0) then
    complain("Failed to load items from the inventory.")
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
  complain("Failed to complete the anvil drop.")
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
