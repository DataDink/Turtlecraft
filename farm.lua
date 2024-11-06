if (not turtle) then error("farm requires a turtle") end

os.loadAPI('turtle.crop.api')

local timer = arg and tonumber(arg[1]) or 10
local drop = arg and arg[2] == "down" and turtle.dropDown or turtle.dropUp

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Farm checks for crops in the spaces around it.")
  print("Mature crops are harvested & replanted and the yield is ejected up or down.")
  print("farm [<interval:number> [<eject:up/down> [whitelist=expr blacklist=expr...]]")
  print("")
  print(message)
end
display("")

function checkSpace()
  for i = 1,16 do
    if (turtle.getItemCount(i) == 0) then return true end
  end
  return false
end

function tryHarvest()
  local name = (turtle.inspect() or {}).name
  local harvested, reason = turtle.dig()
  if (not harvested) then display("Harvest failed: " .. tostring(reason)) end
  os.sleep(1)
  turtle.suck()
  return harvested, name
end

function tryReplant(prefer)
  for rescan = 1,2 do
    for i = 1,16 do
      local name = (turtle.getItemInfo(i) or {}).name
      if (name and (not prefer or name == prefer)) then
        local placed, reason = turtle.place()
        if (placed) then return true end
        display("Replant failed: " .. tostring(reason))
      end
    end
    prefer = nil
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
  os.sleep(timer)
  if (not checkSpace() and not tryEject()) then
    display("Inventory full")
  else
    local mature, reason = turtle.crop.mature()
    display("Inspecting: " .. tostring(mature) .. "/" .. tostring(reason))
    if (mature) then
      turtle.select(1)
      local harvested, name = tryHarvest()
      if (harvested) then tryReplant(name) end
    end
  end
  turtle.turnRight()
end
