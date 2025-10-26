if (arg and arg[1] == "help") then
  print("Usage: tunnel")
  print("Control the turtle with the keyboard.")
  return
end

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
  print('Press [space] to build walls')
  print('Press [enter] to exit')
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

function place(method, detect)
  if (detect()) then return end
  for slot = 1, 16 do
    if (turtle.getItemCount(slot) > 0) then
      turtle.select(slot)
      if (method()) then return end
    end
  end
end

function floor() return place(turtle.placeDown, turtle.detectDown) end
function wall() return place(turtle.place, turtle.detect) end

while (true) do
  display('')

  local _, key = os.pullEvent('key')
  refuel()
  if (key == keys.w) then
    if (not turtle.forward()) then
      turtle.dig()
      turtle.attack()
      turtle.forward()
    end
    if (turtle.detectUp()) then turtle.digUp() end
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
  if (key == keys.a) then
    turtle.turnLeft()
  end
  if (key == keys.d) then
    turtle.turnRight()
  end
  if (key == keys.space) then
    turtle.turnLeft()
    wall()
    turtle.turnRight()
    turtle.turnRight()
    wall()
    turtle.turnLeft()
  end
  if (key == keys.enter) then
    term.clear()
    term.setCursorPos(1,1)
    print('Tunnel complete')
    return;
  end
  floor()
end
