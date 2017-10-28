local cfgjson = "{\"minify\":false,\"maxDigs\":300,\"maxMoves\":10,\"maxAttacks\":64,\"recoveryPath\":\"turtlecraft/recovery/\",\"version\":\"2.0.0\",\"pastebin\":\"kLMahbgd\",\"build\":\"1509210979504\",\"env\":\"debug\"}";
TurtleCraft = {};

(function()
  local modules = {};
  TurtleCraft.export = function(name, module)
    if (modules[name] ~= nil) then error('module ' .. name .. ' exists'); end
    local resolved = type(module) ~= 'function';
    modules[name] = {resolved = resolved, value = module};
  end
  TurtleCraft.import = function(name)
    if (not modules[name]) then error('module ' .. name .. ' does not exist.'); end
    if (not modules[name].resolved) then
      modules[name].value = modules[name].value();
      modules[name].resolved = true;
    end
    return modules[name].value;
  end
end)();

TurtleCraft.export('services/config', function()
  -- NOTE: cfgjson will be added to the turtlecraft scope at build time
  local config =  TurtleCraft.import('services/json').parse(cfgjson or '{}');
  config.recoveryPath = config.recoveryPath:gsub('[%s/]+$', '');
  return config;
end)

TurtleCraft.export('services/io', function()
  local IO = {};

  IO.readKey = function(timeout)
    if (timeout) then os.startTimer(timeout); end
    local event, code, held;
    repeat
      event, code, held = os.pullEvent();
    until (event == "key" or event == "timer");
    if (event == "timer") then return false, false; end
    return code, held;
  end

  IO.setCancelKey = function(code, func)
    parallel.waitForAny(func, function()
      local input;
      repeat
        _, input = os.pullEvent('key');
      until (input == code);
    end);
  end

  IO.centerLine = function(text, fill, line)
    if (line == nil) then
      _, line = term.getCursorPos();
    end
    local width = term.getSize();
    local inset = math.ceil(width/2 - text:len()/2);
    if (inset < 0) then
      term.setCursorPos(1, line);
      term.write(text:sub(math.abs(inset) + 1, inset - 1));
      return;
    end
    if (fill ~= nil) then
      term.setCursorPos(1, line);
      term.write(fill:rep(width));
    end
    term.setCursorPos(inset, line);
    term.write(text);
  end

  IO.centerPage = function(text, fill)
    local lines = {};
    for line in text:gmatch('[^\n]+') do
      table.insert(lines, line);
    end
    local lineCount = #lines;
    local _, height = term.getSize();
    local start = math.floor(height/2-lineCount/2);
    for i = 1, lineCount do
      IO.centerLine(lines[i], fill, start + i);
    end
  end

  return IO;

end);

TurtleCraft.export('services/json', function()
  local Json = {};

  Json.trim = function(content)
    return content:gsub('^%s+', ''):gsub('%s+$', '');
  end

  Json.parseNull = function(content)
    if (not content:lower():find('^%s*null')) then return false, nil, content; end
    local remaining = content:gsub('^%s*null', '');
    return true, nil, remaining;
  end

  Json.parseNumber = function(content)
    if (not content:find('^%s*-?%d+')) then return false, nil, content; end
    local remaining = Json.trim(content);
    local value = remaining:match('^-?%d+') or remaining:match('^-?%d+%.%d+');
    remaining = remaining:sub(value:len() + 1);
    return true, tonumber(value), remaining;
  end

  Json.parseBoolean = function(content)
    local remaining = Json.trim(content);
    local value = remaining:lower():match('^true') or remaining:lower():match('^false');
    if (value == nil) then return false, nil, remaining; end
    remaining = remaining:sub(value:len() + 1);
    return true, value == 'true', remaining;
  end

  Json.parseString = function(content)
    if (not content:find('^%s*"')) then return false, nil, content; end
    local remaining = content:gsub('^%s*"', '');
    local value = '';
    local chunk = remaining:match('^[^\\"]*[\\"]');
    while (chunk ~= nil) do
      remaining = remaining:sub(chunk:len() + 1);

      if (chunk:sub(-1) == '"') then
        value = value .. chunk:sub(1, -2);
        return true, value, remaining;
      end

      value = value .. chunk:sub(1, -2);
      local chr = remaining:sub(1,1);
      remaining = remaining:sub(2);

      if (chr == '"') then value = value .. '"'; end
      if (chr == '\\') then value = value .. '\\'; end
      if (chr == '/') then value = value .. '/'; end
      if (chr == 'b') then value = value .. '\b'; end
      if (chr == 'f') then value = value .. '\f'; end
      if (chr == 'n') then value = value .. '\n'; end
      if (chr == 'r') then value = value .. '\r'; end
      if (chr == 't') then value = value .. '\t'; end
      if (chr == 'u') then
        local hex = tonumber(remaining:sub(1, 4), 16) % 256;
        remaining = remaining:sub(5);
        value = value .. string.char(hex);
      end
      chunk = remaining:match('[^\\"]*[\\"]');
    end
    return false, remaining:len();
  end

  Json.parseArray = function(content)
    if (not content:find('^%s*%[')) then return false, nil, content; end
    local result = {};
    local valid, value, remaining = Json.parseNext(content:gsub('^%s*%[', ''));
    while (valid) do
      table.insert(result, value);
      remaining = Json.trim(remaining);
      local delim = remaining:sub(1, 1);
      remaining = remaining:sub(2);
      if (delim == ']') then return true, result, remaining; end
      if (delim ~= ',') then return false, remaining:len(); end
      valid, value, remaining = Json.parseNext(remaining);
    end
    return false, remaining:len();
  end

  Json.parseObject = function(content)
    if (not content:find('^%s*%{')) then return false, nil, content; end
    local result = {};
    local valid, key, remaining = Json.parseString(content:gsub('^%s*%{', ''));
    while (valid) do
      remaining = Json.trim(remaining);
      if (remaining:sub(1,1) ~= ':') then return false, remaining:len(); end
      remaining = remaining:sub(2);
      local continue, value, remaining2 = Json.parseNext(remaining);
      remaining = remaining2;
      if (not continue) then return false; end
      result[key] = value;
      remaining = Json.trim(remaining);
      local delim = remaining:sub(1,1);
      remaining = remaining:sub(2);
      if (delim == '}') then return true, result, remaining; end
      if (delim ~= ',') then return false, remaining:len(); end
      valid, key, remaining = Json.parseString(remaining);
    end
    return false, remaining:len();
  end

  Json.parseNext = function(content)
    for i, parser in ipairs({Json.parseNull, Json.parseNumber, Json.parseBoolean, Json.parseString, Json.parseArray, Json.parseObject}) do
      local success, value, remaining = parser(content);
      if (success) then return true, value, remaining; end
    end
    return false, content:len();
  end

  Json.parse = function(content)
    local success, value = Json.parseNext(content);
    if (success) then return value; else return nil; end
  end

  Json.format = function(value)
    if (type(value) == 'nil') then return 'null'; end
    if (type(value) == 'boolean') then return tostring(value); end
    if (type(value) == 'number') then return tostring(value); end
    if (type(value) == 'string') then
      value = value:gsub('\\', '\\\\');
      value = value:gsub('\"', '\\"');
      value = value:gsub('\/', '\\/');
      value = value:gsub('\b', '\\b');
      value = value:gsub('\f', '\\f');
      value = value:gsub('\n', '\\n');
      value = value:gsub('\r', '\\r');
      value = value:gsub('\t', '\\t');
      return '"' .. value .. '"';
    end
    if (type(value) == 'table' and #value > 0) then
      local array = {};
      for i, content in ipairs(value) do
        table.insert(array, Json.format(content));
      end
      return '[' .. table.concat(array, ',') .. ']';
    end
    if (type(value) == 'table') then
      local members = {};
      for k, v in pairs(value) do
        table.insert(members, '"' .. k .. '":' .. Json.format(v));
      end
      return '{' .. table.concat(members, ',') .. '}';
    end
  end

  return Json;
end);

TurtleCraft.export('services/plugins', function()
  local register = {};

  local function sort(array, by, next)
    local grouped = {};
    for _, v in ipairs(array) do
      local key = by(v);
      if (grouped[key] == nil) then grouped[key] = {}; end
      table.insert(grouped[key], v);
    end

    local sorted = {};
    for k in pairs(grouped) do
      table.insert(sorted, k);
    end
    table.sort(sorted);

    local result = {};
    for _, k in ipairs(sorted) do
      if (next and #grouped[k] > 0) then grouped[k] = next(grouped[k]); end
      for _, v in ipairs(grouped[k]) do
        table.insert(result, v);
      end
    end

    return result;
  end

  return {
    list = function()
      local sorted = sort(
        register,
        function(r) return r.order; end,
        function(grouped) return sort(
          grouped,
          function(i) return i.title; end
        ); end
      );
      local items = {};
      for _, v in ipairs(sorted) do
        table.insert(items, {title=v.title,start=v.start});
      end
      return items;
    end,

    register = function(title, start, order)
      local usage = 'Usage: TurtleCraft.import("services/plugins").register(<title>, <start function>, <optional order>);';
      if (type(start) ~= 'function') then error(usage); end
      if (type(title) ~= 'string') then error(usages); end
      if (order ~= nil and type(order) ~= 'number') then error(usage); end
      title = title:gsub('^%s+', ''):gsub('%s+$', '');
      order = order or 0;
      for _, v in ipairs(register) do
        if (title:lower() == v.title:lower()) then error('Plugin "' .. title .. '" already registered!'); end
      end
      table.insert(register, {title=title, start=start, order=order});
    end
  }
end);

-- Recovery
-- Provides simple recovery functionality
-- Use in place of normal turtle movement functions
-- Coordinates and facing based on / relative to initial placement or last .reset()

-- Recovery.moveTo(x, y, z)     :: moves the turtle to the coordinates
-- Recovery.digTo(x, y, z)      :: digs and attacks the turtle to the coordinates
-- Recovery.excavateTo(x, y, z) :: same as digTo, but adds up/down digging
-- Recovery.face(d)             :: 0 = forward, 1 = right, 2 = backward, 3 = left
-- Recovery.start(cmd)          :: starts a recovery command that will be restarted if interrupted
--                              :: format: <module name> <method name> <param a> <param b> ...
--                              :: example: Recovery.start("services/recovery moveTo 12 15 22")
-- Recovery.finish()            :: completes the previously started recovery command so that it will not be re-initiated after an interruption
-- Recovery.reset()             :: sets the current turtle location and facing coordinates to 0,0,0,0


TurtleCraft.export('services/recovery', function()
  local config = TurtleCraft.import('services/config');
  local IO = TurtleCraft.import('services/io');
  local location = {x=0,y=0,z=0,f=0};
  local positionFile = config.recoveryPath .. '/position.dat';
  local position = fs.open(positionFile, 'a');
  local taskFile = config.recoveryPath .. '/tasks.dat';
  local tasks = {};
  local pvt = {};

  ----------------------> Public API
  local Recovery = {
    location = {},

    face = function(direction)
      local turns = (direction%4) - location.facing;
      if (turns == 0) then return true; end;
      if (turns > 2) then turns = -1; end
      if (turns < -2) then turns = 1; end
      local method = (turns > 0) and turtle.turnRight or turtle.turnLeft;
      local name = (turns > 0) and 'right' or 'left';
      for i=1, math.abs(turns) do
        method();
        position.writeLine(name);
        position.flush();
      end
      location.facing = (location.facing + turns)%4
      return true;
    end,

    moveTo = function(x, y, z)
      return pvt.navigateTo('moveTo', pvt.moveForward, pvt.moveUp, pvt.moveDown, x, y, z);
    end,

    digTo = function(x, y, z)
      return pvt.navigateTo('digTo', pvt.digForward, pvt.digUp, pvt.digDown, x, y, z);
    end,

    excavateTo = function(x, y, z)
      return pvt.navigateTo('excavateTo', pvt.excavateForward, pvt.excavateUp, pvt.excavateDown, x, y, z);
    end,

    start = function(command)
      local file = fs.open(taskFile, 'a');
      file.writeLine(command);
      file.close();
      table.insert(tasks, command);
    end,

    finish = function()
      local file = fs.open(taskFile, 'a');
      file.writeLine('end');
      file.close();
      table.remove(tasks);
      local remaining = pvt.readTasks();
      if (#remaining == 0) then
        fs.open(taskFile, 'w').close();
        local posCmd = 'location ' .. location.x .. ' ' .. location.y .. ' ' .. location.z .. ' ' .. location.f;
        position.close();
        position = fs.open(positionFile, 'w');
        position.writeLine(posCmd); -- resets position file so it doesn't get huge.
      end
    end,

    recover = function()
      TurtleCraft.import('views/notification')
        .show('Recovering...\nPress ESC to cancel');
      local code = IO.readKey(60);
      if (code == keys.esc) then return; end
      TurtleCraft.import('views/notification')
        .show('Recovering\nLast Session');
      pvt.recoverPosition();
      pvt.recoverTasks();
    end,

    reset = function()
      fs.open(taskFile, 'w');
      tasks = {};
      position = fs.open(positionFile, 'w');
      location = {x = 0, y = 0, z = 0, f = 0};
    end
  };

  ----------------------> Location Stuff
  setmetatable(Recovery.location, {
    __index = location,
    __newindex = function() return; end,
  });

  pvt.processForward = function()
    if (location.facing == 0) then location.y = location.y + 1; end
    if (location.facing == 1) then location.x = location.x + 1; end
    if (location.facing == 2) then location.y = location.y - 1; end
    if (location.facing == 3) then location.x = location.x - 1; end
  end

  pvt.processDown = function()
    location.z = location.z - 1;
  end

  pvt.processUp = function()
    location.z = location.z + 1;
  end

  pvt.processRight = function()
    location.f = (location.f + 1) % 4;
  end

  pvt.processLeft = function()
    location.f = (location.f - 1) % 4;
  end

  ----------------------> Recovery Stuff
  pvt.readTasks = function()
    if (not fs.exists(taskFile)) then return {}; end
    local items = {};
    local file = fs.open(taskFile, 'r');
    local line = file.readLine();
    while (line) do
      if (line == 'end') then
        table.remove(items);
      else
        table.insert(items, line);
      end
      local line = file.readLine();
    end
    file.close();
    return items;
  end

  pvt.recoverPosition = function()
    if (not fs.exists(positionFile)) then return; end
    local previous = fs.open(config.recoveryPath, 'r');
    local cmd = previous.readLine();
    while (cmd) do
      if (cmd == 'forward') then pvt.processForward(); end
      if (cmd == 'up') then pvt.processUp(); end
      if (cmd == 'down') then pvt.processDown(); end
      if (cmd == 'left') then pvt.processLeft(); end
      if (cmd == 'right') then pvt.processRight(); end

      if (cmd:match('^location %d+ %d+ %d+ %d$')) then
        local values = cmd:gmatch('%d+');
        location.x = tonumber(values());
        location.y = tonumber(values());
        location.z = tonumber(values());
        location.f = tonumber(values());
      end
      cmd = previous.readLine();
    end
    previous.close();
    position = fs.open(positionFile, 'w');
    position.writeLine('location ' .. position.x .. ' ' .. position.y .. ' ' .. position.z .. ' ' .. position.f);
  end

  pvt.recoverTasks = function()
    if (not fs.exists(taskFile)) then return; end
    local recTasks = pvt.readTasks();
    local file = fs.open(taskFile, 'w');
    for _, task in ipairs(recTasks) do
      file.writeLine(task);
    end
    file.close();

    for _, task in ipairs(recTasks) do
      pvt.exec(task);
    end
  end

  pvt.exec = function(cmd)
    local parts = cmd:gsub('[^%s]+');
    local module = parts();
    local method = parts();
    local values = {};
    local value = parts();
    while (value) do
      if (value:match('^%d+%.%d+$|^%d+$')) then value = tonumber(value); end
      if (value:upper() == 'TRUE') then value = true; end
      if (value:upper() == 'FALSE') then value = false; end
      table.insert(values, value);
      value = parts();
    end
    local lib = TurtleCraft.import(module);
    local func = lib[method];
    func(table.unpack(values));
  end

  ----------------------> Move Stuff
  pvt.moveForward = function()
    return pvt.retry(function()
      if (turtle.forward()) then
        position.writeLine('forward');
        position.flush();
        pvt.processForward();
        return true;
      end
      return false;
    end, config.maxMoves);
  end

  pvt.moveUp = function()
    return pvt.retry(function()
      if (turtle.up()) then
        position.writeLine('up');
        position.flush();
        pvt.processUp();
        return true;
      end
      return false;
    end, config.maxMoves);
  end

  pvt.moveDown = function()
    return pvt.retry(function()
      if (turtle.down()) then
        position.writeLine('down');
        position.flush();
        pvt.processDown();
        return true;
      end
      return false;
    end, config.maxMoves);
  end

  ----------------------> Dig Stuff
  pvt.digDetect = function(digMethod, detectMethod)
    return pvt.retry(function()
      if (not detectMethod()) then return true; end
      digMethod();
      return not detectMethod();
    end, config.maxDigs);
  end

  pvt.digMove = function(detectMethod, digMethod, attackMethod, moveMethod)
    return pvt.retry(function()
      if (not pvt.digDetect(detectMethod, digMethod)) then return false; end
      attackMethod();
      return moveMethod();
    end, config.maxAttacks);
  end

  pvt.digForward = function()
    return pvt.digMove(turtle.detect, turtle.dig, turtle.attack, function()
      if (turtle.forward()) then
        position.writeLine('forward');
        position.flush();
        pvt.processForward();
        return true;
      end
      return false;
    end);
  end

  pvt.digUp = function()
    return pvt.digMove(turtle.detectUp, turtle.digUp, turtle.attackUp, function()
      if (turtle.up()) then
        position.writeLine('up');
        position.flush();
        pvt.processUp();
        return true;
      end
      return false;
    end);
  end

  pvt.digDown = function()
    return pvt.digMove(turtle.detectDown, turtle.digDown, turtle.attackDown, function()
      if (turtle.down()) then
        position.writeLine('down');
        position.flush();
        pvt.processDown();
        return true;
      end
      return false;
    end);
  end

  ---------------------->Excavate Stuff
  pvt.excavateForward = function()
    pvt.digDetect(turtle.detectUp, turtle.digUp);
    pvt.digDetect(turtle.detectDown, turtle.digDown);
    return pvt.digForward();
  end

  pvt.excavateUp = function()
    pvt.digDetect(turtle.detect, turtle.dig);
    return pvt.digUp();
  end

  pvt.excavateDown = function()
    pvt.digDetect(turtle.detect, turtle.dig);
    return pvt.digDown();
  end

  ---------------------->Other Stuff
  pvt.retry = function(method, max)
    for tries = 0, max do
      if (method()) then return true; end
    end
    return false;
  end

  pvt.navigateTo = function(methodName, forwardMethod, upMethod, downMethod, x, y, z)
    Recovery.start('services/recovery ' .. methodName .. ' ' .. x .. ' ' .. y .. ' ' .. z);
    for i = 0, i < 3 do
      while (location.x < x) do
        Recovery.face(1);
        if (not forwardMethod()) then break; end
      end
      while (location.x > x) do
        Recovery.face(3);
        if (not forwardMethod()) then break; end
      end
      while (location.y < y) do
        Recovery.face(0);
        if (not forwardMethod()) then break; end
      end
      while (location.y > y) do
        Recovery.face(2);
        if (not forwardMethod()) then break; end
      end
      while (location.z < z) do
        if (not upMethod()) then break; end
      end
      while (location.z > z) do
        if (not downMethod()) then break; end
      end
    end
    Recovery.finish();
    return (location.x == x and location.y == y and location.z == z);
  end

  return Recovery;
end);

TurtleCraft.export('views/border', function()
  local config = TurtleCraft.import('services/config');
  local IO = TurtleCraft.import('services/io');
  return {
    show = function()
      local w, h = term.getSize();
      IO.centerLine('TurtleCraft v' .. config.version .. ' ' .. config.env, '=', 1);
      for l = 2, h do
        term.setCursorPos(1, l);
        term.write('|');
        term.setCursorPos(w, l);
        term.write('|');
      end
      term.setCursorPos(1, h);
      term.write(('='):rep(w));
    end
  };
end)

TurtleCraft.export('views/notification', function()
  local border = TurtleCraft.import('views/border');
  local IO = TurtleCraft.import('services/io');
  return {
    show = function(message)
      term.clear();
      IO.centerPage(message);
      border.show();
    end
  };
end);

(function()
  local plugins = TurtleCraft.import('services/plugins');
  plugins.register('first', function() end, 0);
  plugins.register('second', function() end, -1);
  plugins.register('third', function() end, 0);
  plugins.register('fourth', function() end, -1);

  local result = plugins.list();
  for _, v in ipairs(result) do
    print(v.title);
  end
end)()
