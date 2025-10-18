if (not turtle) then error("Error: Drop requires a turtle") end

function waitEnter()
  local key = nil
  while key ~= keys.enter do
    local _, key = os.pullEvent("key")
  end
end

function instruct()
  term.clear()
  term.setCursorPos(1, 1)
  print("** Anvil Drop Instructions **")
  print()
  print("- Put a block placer above the turtle")
  print("- Insert Anvil")
  print("- Insert Item(s)")
  print()
  print("Press enter to continue...")
  waitEnter()
end

function find()
  for i = 1, 16 do
    local detail = turtle.getItemDetail(i)
    if (not detail) then continue end
    if (detail.name == "minecraft:anvil" or detail.name == "minecraft:chipped_anvil" or detail.name == "minecraft:damaged_anvil") then
      return i
    end
  end
end

function complain(items)
  term.clear()
  term.setCursorPos(1, 1)
  print("** Anvil Drop **")
  print()
  print("Missing anvil...")
  print()
  os.sleep(2)
end

function waitAnvil()
  term.clear()
  term.setCursorPos(1, 1)
  print("** Anvil Drop **")
  print()
  print("Awaiting anvil drop...")
  while (not turtle.detect()) do os.sleep(0.1) end
end

if (turtle.detect()) then turtle.dig() end
turtle.suck()

while (true) do
  instruct()

  local found = find()

  if (found) then
    for (i = 1, 16) do
      if (i ~= found && turtle.getItemCount(i) > 0) then
        turtle.select(i)
        turtle.drop(1)
      end
    end
    turtle.select(found)
    turtle.dropUp()
    redstone.setOutput("top", true)
    os.sleep(1)
    redstone.setOutput("top", false)
    waitAnvil()

    turtle.dig()
    turtle.suck()
    os.sleep(1)
    turtle.suck()
  else 
    complain()
  end
end
