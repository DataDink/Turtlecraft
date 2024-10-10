if (not turtle) then error("Error: Drop requires a turtle") end

local time = arg and tonumber(arg[1]) or 10
local count = arg and tonumber(arg[2]) or 64

function display(message)
  print("Drop keeps dropped items refreshed so they don't get deleted.")
  print('Items are picked up and re-ejected at a regular interval.')
  print('drop [<interval:number> [<count:number>]]')
  print('')
  print(message)
end

while (true) do
  local drop = not turtle.detectDown() and turtle.dropDown
            or not turtle.detectUp() and turtle.dropUp
            or not turtle.detect() and turtle.drop
            or (function() end)

  local remaining = count
  for slot = 1, 16 do
    local stack = turtle.getItemCount(slot)
    if (stack > 0) then
      turtle.select(slot)
      drop(math.min(remaining, stack))
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
