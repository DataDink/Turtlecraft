if (not turtle) then error("Error: Drop requires a turtle") end

local time = arg and tonumber(arg[1]) or 10
local count = arg and tonumber(arg[2]) or 64
local direction = arg and tostring(arg[3])

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Drop keeps dropped items refreshed so they don't get deleted.")
  print('Items are picked up and re-ejected at a regular interval.')
  print('drop [<interval:number> [<count:number> [<direction:up/down/forward]]]')
  print('')
  print(message)
end

function eject(count)
  if (direction == 'down') then return turtle.dropDown(count) end
  if (direction == 'up') then return turtle.dropUp(count) end
  if (direction == 'forward' then return turtle.drop(count) end
  if (turtle.detectDown() and turtle.detectUp()) then return turtle.drop(count) end
  if (turtle.detectDown()) then return turtle.dropUp(count) end
  return turtle.dropDown(count)
end

while (true) do
  local remaining = count
  for slot = 1, 16 do
    local stack = turtle.getItemCount(slot)
    if (stack > 0) then
      turtle.select(slot)
      eject(math.min(remaining, stack))
      local undropped = turtle.getItemCount(slot)
      remaining = remaining - stack + undropped
      if (remaining < 1) then break end
    end
  end
  turtle.select(1)

  display("waiting for " .. time .. " seconds...")
  os.sleep(time)
  display("dropping up to " .. count .. " items...")
  turtle.suck()
  turtle.suckUp()
  turtle.suckDown()
end
