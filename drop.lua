print("Because solengolias don't stop everything...")
print('')

if (not turtle) then
  print("Error: Drop requires a turtle")
  return
end

local time = tonumber(arg[1]) or 10
local count = tonumber(arg[2]) or 64

print('Dropping stacks of ' .. count .. ' items for ' .. time .. ' seconds at a time.')
print('This turtle should be encased leaving space above, below or in front for ejected items.')
print('Hold ctrl-T to stop this process.')

while (true) do
  local drop = not turtle.detectDown() and turtle.dropDown
            or not turtle.detectUp() and turtle.dropUp
            or not turtle.detect() and turtle.drop
            or (function() end)

  local remaining = count
  for slot = 1, 16 do
    local stack = turtle.getItemCount(i)
    if (stack) then
      turtle.select(i)
      drop(math.min(remaining, stack))
      local undropped = turtle.getItemCount(i)
      remaining = remaining - stack + undropped
      if (remaining < 1) then break end
    end
  end

  local timer, id = os.startTimer(time)
  while (timer ~= id) do local _, id = os.pullEvent("timer") end
  turtle.suck()
  turtle.suckUp()
  turtle.suckDown()
end
