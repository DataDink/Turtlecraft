if (not turtle) then error("drive requires a turtle") end

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print('Control the turtle with the keyboard:')
  print('')
  print('        forward')
  print('           w')
  print('   left a  s  d right')
  print('        reverse')
  print('')
  print('  [space] [x] [enter]')
  print('    up   down   exit')
  print('')
  print(message)
end

function refuel()
  display('')
  if (turtle.getFuelLevel() > 0) then return end
  for slot = 1, 16 do
    if (turtle.getItemCount(slot) > 0) then
      turtle.select(slot)
      if (turtle.refuel(1)) then return end
    end
  end
  display('No fuel available')
end

while (true) do
  display('')

  local _, key = os.pullEvent('key')
  refuel()
  if (key == keys.space) then
    if (not turtle.up()) then
      turtle.digUp()
      turtle.attackUp()
      turtle.up()
    end
  end
  if (key == keys.x) then
    if (not turtle.down()) then
      turtle.digDown()
      turtle.attackDown()
      turtle.down()
    end
  end
  if (key == keys.a) then
    turtle.turnLeft()
  end
  if (key == keys.d) then
    turtle.turnRight()
  end
  if (key == keys.w) then
    if (not turtle.forward()) then
      turtle.dig()
      turtle.attack()
      turtle.forward()
    end
  end
  if (key == keys.s) then
    if (not turtle.back()) then
      turtle.turnLeft()
      turtle.turnLeft()
      turtle.dig()
      turtle.attack()
      turtle.forward()
      turtle.turnLeft()
      turtle.turnLeft()
    end
  end
  if (key == keys.enter) then
    term.clear()
    term.setCursorPos(1,1)
    print('Drive complete')
    return;
  end
end
