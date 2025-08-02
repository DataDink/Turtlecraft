if (not turtle) then error("tunnel requires a turtle") end
local width, height = term.getSize()

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print('Tunnel with the keyboard:')
  print('')
  print('        forward')
  print('           w')
  print('   left a  s  d right')
  print('        reverse')
  print('')
  print('Press [space] to build')
  print('Press [enter] to exit')
  print('')
  print(message)
end

function refuel()
  display('')
  if (turtle.getFuelLevel() > 0) then return end
  for slot = 1, 16 do
    turtle.select(slot)
    if (turtle.refuel(1)) then return end
  end
  display('No fuel available')
end

function place(method)
  if (not turtle.detectDown()) then
    for slot = 1, 16 do
      if (turtle.getItemCount(slot) > 0) then
        turtle.select(slot)
        if (method) then return end
      end
    end
  end
end

while (true) do
  display('')

  local _, key = os.pullEvent('key')
  refuel()
  if (turtle.detectUp()) then turtle.digUp() end
  if (key == keys.up) then
    if (not turtle.forward()) then
      turtle.dig()
      turtle.attack()
      turtle.forward()
    end
  end
  if (key == keys.down) then
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
  if (key == keys.left) then
    turtle.turnLeft()
  end
  if (key == keys.right) then
    turtle.turnRight()
  end
  if (key == keys.space) then
    turtle.turnLeft()
    place(turtle.place)
    turtle.turnRight()
    turtle.turnRight()
    place(turtle.place)
    turtle.turnLeft()
  end
  if (key == keys.enter) then
    term.clear()
    term.setCursorPos(1,1)
    print('Drive complete')
    return;
  end
  if (turtle.detectUp()) then turtle.digUp() end
  place(turtle.placeDown)
end
