if (not turtle) then error("farm requires a turtle") end

os.loadAPI('turtle.crop.api')

local timer = arg and tonumber(arg[1]) or 10
local drop = arg and arg[2] == "down" and turtle.dropDown or turtle.dropUp

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Farm checks for crops in the spaces around it.")
  print("Mature crops are harvested & replanted and the yield is ejected up or down.")
  print("farm [<interval:number> [<eject:up/down>]]")
  print("")
  print(message)
end

function checkSpace()
  for i = 1,16 do
    if (turtle.getItemCount(i) == 0) then return true end
  end
  return false
end

function tryHarvest()
  local harvested, reason = turtle.dig()
  if (not harvested) then display("Harvest failed: " .. tostring(reason)) end
  return harvested
end

function tryReplant()
  for i = 1,16 do
    if (turtle.getItemCount(i) > 0 and turtle.select(i)) then
      local placed, reason = turtle.place()
      if (placed) then return true end
      display("Replant failed: " .. tostring(reason))
    end
  end
  return false
end

function tryEject()
  local success = true
  for i = 1,16 do
    if (turtle.getItemCount(i) > 0 and turtle.select(i)) then 
      local ejected, reason = drop() 
      if (not ejected) then display("Eject failed: " .. tostring(reason)) end
      success = success and ejected
    end
  end
  return success
end

while (true) do
  if (not checkSpace() and not tryEject()) then
    display("Inventory full")
  else
    local mature, reason = turtle.crop.mature()
    display("Inspecting: " .. tostring(mature) .. "/" .. tostring(reason))
    local harvest = mature and tryHarvest() and tryReplant() and tryEject()
  end
  os.sleep(timer)
  turtle.turnRight()
end
