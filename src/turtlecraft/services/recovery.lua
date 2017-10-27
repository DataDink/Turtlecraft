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
  local config = TurtleCraft.require('config');
  local IO = TurtleCraft.require('services/io');
  local location = {x=0,y=0,z=0,f=0};
  local positionFile = config.recoveryPath .. 'position.dat';
  local position = fs.open(positionFile, 'a');
  local taskFile = config.recoveryPath .. 'tasks.dat';
  local tasks = {};
  local pvt = {};

  ----------------------> Public API
  local Recovery = {
    location = {},

    face = function(direction)
      direction = direction % 4;
      if (direction == location.facing) then return true; end
      local method = (direction > location.facing) and turtle.turnRight or turtle.turnLeft;
      local turns = math.abs(direction - location.facing);
      if (turns > 2) then
        turns = 1;
        method = (method == turtle.turnRight) and turtle.turnLeft or turtle.turnRight;
      end
      local name = (method == turtle.turnRight) and 'right' or 'left';
      for i=0, turns do
        method();
        position.writeLine(name);
        position.flush();
        if (method == turtle.turnRight) then location.facing = location.facing + 1; end
        if (method == turtle.turnLeft) then location.facing = location.facing - 1; end
      end
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
      TurtleCraft.require('views/notification')
        .show('Recovering...\nPress ESC to cancel');
      local code = IO.readKey(60);
      if (code == keys.esc) then return; end
      TurtleCraft.require('views/notification')
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
    local lib = TurtleCraft.require(module);
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
end)
