if (not turtle) then error("dig requires a turtle") end
local width, height = term.getSize()

while (true) do
  term.clear()
  term.setCursorPos(1,1)
  print('Control the turtle with the keyboard:')
  print('')
  print('           up')
  print('           \24')
  print('   left \27   \26 right')
  print('           \25')
  print('          down')
  print('')
  print('    [space] [enter]')
  print('    forward  exit')

  local _, key = os.pullEvent('key')
  if (key == keys.up) then
    if (not turtle.up()) then
      turtle.refuel(1)
      turtle.digUp()
      turtle.attackUp()
      turtle.up()
    end
  end
  if (key == keys.down) then
    if (not turtle.down()) then
      turtle.refuel(1)
      turtle.digDown()
      turtle.attackDown()
      turtle.down()
    end
  end
  if (key == keys.left) then
    turtle.turnLeft()
  end
  if (key == keys.right) then
    turtle.turnRight()
  end
  if (key == keys.space) then
    if (not turtle.forward()) then
      turtle.refuel(1)
      turtle.dig()
      turtle.attack()
      turtle.forward()
    end
  end
  if (key == keys.enter) then
    term.clear()
    term.setCursorPos(1,1)
    print('Drive complete')
    return;
  end
end
