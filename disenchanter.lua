while (true) do
  if (turtle.detect()) then turtle.dig() end
  turtle.suck()

  term.clear()
  term.setCursorPos(1, 1)
  print("** Disenchanter **")
  print("- Insert Anvil")
  print("- Insert Book(s)")
  print("- Insert Item")
  print("Press any key to continue...")

  os.pullEvent("key")
  local anvil = 0
  local books = 0
  local item = 0

  for (i = 1, 16) do
    local item = turtle.getItemDetail(i)
    if (item) then
      if (item.name == "minecraft:anvil") then anvil = i
      elseif (item.name == "minecraft:book") then books = i
      else item = i end
    end
  end

  if (anvil == 0 or books == 0 or item == 0) then
    term.clear()
    term.setCursorPos(1, 1)
    print("** Disenchanter **")
    print("- Missing Required Items -")
    print("Anvil: " .. (anvil == 0 and "Missing" or "Present"))
    print("Books: " .. (books == 0 and "Missing" or "Present"))
    print("Item: " .. (item == 0 and "Missing" or "Present"))
    print("Press any key to continue...")
    os.pullEvent("key")
  else

    turtle.select(books)
    turtle.drop(1)
    turtle.select(item)
    turtle.drop(1)
    turtle.select(anvil)
    turtle.dropUp()

    term.clear()
    term.setCursorPos(1, 1)
    print("** Disenchanting **")
    print("Awaiting anvil drop...")
    while (not turtle.detect()) do os.sleep(0.1) end

    turtle.dig()
    turtle.suck()
    os.sleep(1)
    turtle.suck()
  end
end
