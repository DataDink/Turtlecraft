if (not turtle) then error("tunnel requires a turtle") end
local width, height = term.getSize()
turtle.select(1)

while (true) do
  term.clear()
  term.setCursorPos(1,1)
  print('Tunnel with the keyboard:')
  print('')
  print('        forward')
  print('           \24')
  print('   left \27     \26 right')
  print('           \25')
  print('        reverse')
  print('')
  print('Press [enter] to exit')

  local _, key = os.pullEvent('key')
  if (turtle.detectUp()) then turtle.digUp() end
  if (key == keys.up) then
    if (not turtle.forward()) then
      turtle.refuel(1)
      turtle.dig()
      turtle.attack()
      turtle.forward()
    end
  end
  if (key == keys.down) then
    if (not turtle.back()) then
      turtle.refuel(1)
      turtle.turnLeft()
      turtle.turnLeft()
      turtle.dig()
      turtle.attack()
      turtle.forward()
      turtle.turnLeft()
      turtle.turnLeft()
    end
  end
  if (key == keys.left) then
    turtle.turnLeft()
  end
  if (key == keys.right) then
    turtle.turnRight()
  end
  if (key == keys.enter) then
    term.clear()
    term.setCursorPos(1,1)
    print('Drive complete')
    return;
  end
  if (turtle.detectUp()) then turtle.digUp() end
end
