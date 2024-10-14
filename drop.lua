if (not turtle) then error("Error: Drop requires a turtle") end

local time = arg and tonumber(arg[1]) or 10
local count = arg and tonumber(arg[2]) or 64
local direction = arg and tostring(arg[3])
local random = arg and tostring(arg[4]) == 'true'

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Drop keeps dropped items refreshed so they don't get deleted.")
  print('Items are picked up and re-ejected at a regular interval.')
  print('drop [<interval:number> [<count:number> [<direction:up/down/forward/auto> [<randomize:true/false>]]]]')
  print('')
  print(message)
end

function eject(count)
  if (direction == 'down') then return turtle.dropDown(count) end
  if (direction == 'up') then return turtle.dropUp(count) end
  if (direction == 'forward') then return turtle.drop(count) end
  if (turtle.detectDown() and turtle.detectUp()) then return turtle.drop(count) end
  if (turtle.detectDown()) then return turtle.dropUp(count) end
  return turtle.dropDown(count)
end

function scanInventory()
  local inventory = {}
  for slot = 1,16 do
    local quantity = turtle.getItemCount(slot)
    if (quantity > 0) then
      table.insert(inventory, {
        slot = slot,
        count = quantity
      })
    end
  end
  return inventory
end

function redstone()
  for k,v in pairs(redstone.getSides()) do
    if (redstone.getInput(v)) then return true end
  end
  return false
end

while (true) do
  local remaining = count
  while (not redstone() and remaining > 0) do
    local inventory = scanInventory()
    if (#inventory == 0) then break; end
    local item = inventory[random and math.random(1,#inventory) or 1]
    local drop = random and 1 or math.min(remaining, item.count)
    if (not turtle.select(item.slot) or not eject(drop)) then
      display("Failed to drop " .. tostring(drop) .. " items from " .. tostring(item.slot))
      os.sleep(10)
    else
      remaining = remaining - drop
    end
  end

  display("waiting for " .. time .. " seconds...")
  os.sleep(time)
  display("dropping up to " .. count .. " items...")
  if (not redstone()) then
    turtle.suck()
    turtle.suckUp()
    turtle.suckDown()
  end
end
