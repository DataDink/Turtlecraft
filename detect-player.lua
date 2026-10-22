if (arg and arg[1] == "help") then
  print("Usage: [recover] detect-player [<range> [, <filter>[, <filter>[, ...]]]]")
  print("* range: number")
  print("    distance in blocks to detect players. (default: 1)")
  print("    less than 1 means unlimited.")
  print("* filter: lua pattern")
  print("    player names to detect. (default: .+)")
  print("    multiple filters are additive. (whitelist)")
  return
end

local INTERVAL = 0.25

local TOKENS = {}
for i = 1, (arg and #arg or 0) do
  for token in string.gmatch(tostring(arg[i]), "[^,%s]+") do
    table.insert(TOKENS, token)
  end
end

local RANGE = 1
if (tonumber(TOKENS[1] or "")) then RANGE = tonumber(table.remove(TOKENS, 1)) end
if (RANGE < 1) then RANGE = -1 else RANGE = math.floor(RANGE) end

local FILTERS = TOKENS
if (#FILTERS == 0) then FILTERS = {".+"} end
for _, filter in pairs(FILTERS) do
  if (not pcall(string.match, "", filter)) then error("Error: invalid filter '" .. filter .. "'") end
end

local last = nil
function display(message)
  if (message == last) then return end
  last = message
  term.clear()
  term.setCursorPos(1,1)
  print("Detect-player emits a redstone signal on all sides")
  print("while a matching player is within range.")
  print("(see `detect-player help` for usage)")
  print('')
  print("range: " .. (RANGE < 0 and "unlimited" or tostring(RANGE)))
  print("filters: " .. table.concat(FILTERS, ", "))
  print('')
  print(message)
end

function isDetector(side)
  for _, type in pairs({peripheral.getType(side)}) do
    if (type == "playerDetector" or type == "player_detector") then return true end
  end
  return false
end

function findDetector()
  -- turtle upgrades mount on the left/right, so an installed module is preferred
  if (turtle) then
    for _, side in pairs({"left", "right"}) do
      if (isDetector(side)) then return peripheral.wrap(side), side end
    end
  end
  for _, side in pairs(redstone.getSides()) do
    if (isDetector(side)) then return peripheral.wrap(side), side end
  end
  return nil
end

function isMatch(name)
  for _, filter in pairs(FILTERS) do
    local pattern = filter
    if (string.sub(pattern, 1, 1) ~= "^") then pattern = "^" .. pattern end
    if (string.sub(pattern, -1) ~= "$") then pattern = pattern .. "$" end
    local ok, match = pcall(string.match, name, pattern)
    if (not ok) then
      emit(false)
      error("Error: invalid filter '" .. filter .. "'")
    end
    if (match) then return true end
  end
  return false
end

function scan(detector)
  local ok, players = pcall(detector.getPlayersInRange, RANGE)
  if (not ok or type(players) ~= "table") then return nil end
  local matches = {}
  for _, name in pairs(players) do
    if (isMatch(name)) then table.insert(matches, name) end
  end
  return matches
end

function emit(state)
  for _, side in pairs(redstone.getSides()) do
    redstone.setOutput(side, state)
  end
end

local active = false
emit(false)
while (true) do
  local detector, side = findDetector()
  local players = detector and scan(detector)
  if (not players) then
    if (active) then emit(false) end
    active = false
    display(detector and "player detector on " .. side .. " failed, retrying..." or "no player detector found, searching...")
    os.sleep(5)
  else
    local found = #players > 0
    if (found ~= active) then emit(found) end
    active = found
    if (found) then
      display("detected: " .. table.concat(players, ", "))
    else
      display("using player detector on " .. side .. ", no players in range")
    end
    os.sleep(INTERVAL)
  end
end
