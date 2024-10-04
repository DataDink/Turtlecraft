os.loadAPI('turtle.boundary.api')
os.loadAPI('turtle.metadata.api')

local rest = arg and arg[1] and tonumber(arg[1]) or 60*10
local fuelSlot = arg and arg[2] and tonumber(arg[2]) or 1
local seedSlot = arg and arg[3] and tonumber(arg[3]) or 2

local knownCrops = {}
knownCrops['minecraft:wheat'] = 7
knownCrops['minecraft:carrots'] = 7
knownCrops['minecraft:potatoes'] = 7
knownCrops['actuallyadditions:block_canola'] = 7
knownCrops['actuallyadditions:block_rice'] = 7
knownCrops['actuallyadditions:block_coffee'] = 7
knownCrops['actuallyadditions:block_flax'] = 7
knownCrops['minecraft:reeds'] = 0
knownCrops['natura:cotton_crop'] = 4
knownCrops['natura:barley_crop'] = 3

function display(status)
  term.clear()
  term.setCursorPos(1,1)
  print('## Farming Crops')
  print('Place the turtle above the crops and set a perimeter around the turtle for the area to be farmed.')
  print('* Place fuel in slot: ' .. fuelSlot .. '.')
  print('* Place seeds in slot: ' .. seedSlot .. '.')
  if (status) then
    print('')
    print(tostring(status))
  end
end
display()

function awaitSpace() 
  while (true) do
    for i = 1,16 do
      if (turtle.getItemCount(i) == 0) then 
        display() 
        return
      end
    end
    display('Please clear some inventory space')
    os.sleep(1)
  end
end

function plant()
  turtle.select(seedSlot)
  while (turtle.getItemCount(seedSlot) < 2) do
    display('Please add more seeds to slot: ' .. seedSlot)
    os.sleep(1)
  end
  turtle.placeDown()
  display()
end

function refuel()
  if (turtle.getFuelLevel() > 0) then return end
  while (turtle.getFuelLevel() == 0 and turtle.getItemCount(fuelSlot) < 2) do
    display('Please add more fuel to slot: ' .. fuelSlot)
    os.sleep(1)
  end
  while (turtle.getItemCount(fuelSlot) > 1 and turtle.getFuelLevel() < turtle.getFuelLimit()) do
    display('Refueling... (munch, munch)')
    turtle.refuel(1)
  end
  display()
end

(function()
  while (true) do
    repeat
      awaitSpace()
      display('Farming... (work, work)')
      local success, data = turtle.inspectDown()
      local isCrop = data and data.state and data.state.age and true or false
      if (isCrop and not knownCrops[data.name]) then
        display('Stopped! Unknown crop: ' .. data.name)
        return
      end
      if (isCrop and data.state.age >= knownCrops[data.name]) then  
        turtle.digDown()
        turtle.suckDown()
        plant()
      end
      refuel()
    until (not turtle.boundary.next())
    display('Resting... (yawn)')
    os.sleep(rest)
  end
end)()
