-- Recovery
-- Provides simple recovery functionality
-- Use in place of normal turtle movement functions
-- Coordinates and facing based on / relative to initial placement or last .reset()

-- Recovery.moveTo(x, y, z)     :: moves the turtle to the coordinates
-- Recovery.digTo(x, y, z)      :: digs and attacks the turtle to the coordinates
-- Recovery.excavateTo(x, y, z) :: same as digTo, but adds up/down digging
-- Recovery.face(d)             :: 0 = forward, 1 = right, 2 = backward, 3 = left
-- Recovery.start(...)          :: starts a recovery command that will be restarted if interrupted
--                              :: format: <module name> <method name> <param a> <param b> ...
--                              :: example: Recovery.start("services/recovery moveTo 12 15 22")
-- Recovery.finish()            :: completes the previously started recovery command so that it will not be re-initiated after an interruption
-- Recovery.reset()             :: sets the current turtle location and facing coordinates to 0,0,0,0


TurtleCraft.export('services/recovery', function()
  local Recovery, location, pvt;
  local config = TurtleCraft.import('services/config');
  local log = TurtleCraft.import('services/logger');
  local IO = TurtleCraft.import('services/io');
  local positionFile = config.recoveryPath .. '/position.dat';
  local position = fs.open(positionFile, 'a');
  local taskFile = config.recoveryPath .. '/tasks.dat';
  local tasks = {};

  Recovery = {
    location = {},

    face = function(direction)
      log.info('Recovery.face', direction);

      local turns = (direction % 4) - location.f;
      if (turns == 0) then return true; end;
      if (turns > 2) then turns = -1; end
      if (turns < -2) then turns = 1; end
      local method = (turns > 0) and turtle.turnRight or turtle.turnLeft;
      local name = (turns > 0) and 'right' or 'left';
      for i=1, math.abs(turns) do
        method();
        position.writeLine(name);
        position.flush();
        pvt.cleanPosition();
      end
      location.f = (location.f + turns) % 4
      return true;
    end,

    moveTo = function(x, y, z)
      return pvt.navigateTo('moveTo', Recovery.moveForward, Recovery.moveUp, Recovery.moveDown, x, y, z);
    end,

    moveForward = function()
      log.info('Recovery.moveForward');

      return pvt.retry(function()
        if (turtle.forward()) then
          position.writeLine('forward');
          position.flush();
          pvt.cleanPosition();
          pvt.processForward();
          return true;
        end
        return false;
      end, config.maxMoves);
    end,

    moveUp = function()
      log.info('Recovery.moveUp');

      return pvt.retry(function()
        if (turtle.up()) then
          position.writeLine('up');
          position.flush();
          pvt.cleanPosition();
          pvt.processUp();
          return true;
        end
        return false;
      end, config.maxMoves);
    end,

    moveDown = function()
      log.info('Recovery.moveDown');

      return pvt.retry(function()
        if (turtle.down()) then
          position.writeLine('down');
          position.flush();
          pvt.cleanPosition();
          pvt.processDown();
          return true;
        end
        return false;
      end, config.maxMoves);
    end,

    digTo = function(x, y, z)
      return pvt.navigateTo('digTo', Recovery.digForward, Recovery.digUp, Recovery.digDown, x, y, z);
    end,

    digForward = function()
      log.info('Recovery.digForward');

      return pvt.digMove(turtle.detect, turtle.dig, turtle.attack, function()
        if (turtle.forward()) then
          position.writeLine('forward');
          position.flush();
          pvt.cleanPosition();
          pvt.processForward();
          return true;
        end
        return false;
      end);
    end,

    digUp = function()
      log.info('Recovery.digUp');

      return pvt.digMove(turtle.detectUp, turtle.digUp, turtle.attackUp, function()
        if (turtle.up()) then
          position.writeLine('up');
          position.flush();
          pvt.cleanPosition();
          pvt.processUp();
          return true;
        end
        return false;
      end);
    end,

    digDown = function()
      log.info('Recovery.digDown');

      return pvt.digMove(turtle.detectDown, turtle.digDown, turtle.attackDown, function()
        if (turtle.down()) then
          position.writeLine('down');
          position.flush();
          pvt.cleanPosition();
          pvt.processDown();
          return true;
        end
        return false;
      end);
    end,

    excavateTo = function(x, y, z)
      return pvt.navigateTo('excavateTo', Recovery.excavateForward, Recovery.excavateUp, Recovery.excavateDown, x, y, z);
    end,

    excavateForward = function()
      log.info('Recovery.excavateForward');

      pvt.digDetect(turtle.detectUp, turtle.digUp);
      pvt.digDetect(turtle.detectDown, turtle.digDown);
      return Recovery.digForward();
    end,

    excavateUp = function()
      log.info('Recovery.excavateUp');

      pvt.digDetect(turtle.detect, turtle.dig);
      return Recovery.digUp();
    end,

    excavateDown = function()
      log.info('Recovery.excavateDown');

      pvt.digDetect(turtle.detect, turtle.dig);
      return Recovery.digDown();
    end,

    start = function(...)
      log.info('Recovery.start');

      local args = table.pack(...);
      for i, v in ipairs(args) do args[i] = tostring(v); end
      local command = table.concat(args, ' ');
      local file = fs.open(taskFile, 'a');
      file.writeLine(command);
      file.close();
      table.insert(tasks, command);
    end,

    finish = function()
      log.info('Recovery.finish');

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
      log.info('Recovery.recover');

      pvt.recoverPosition();
      if (#pvt.readTasks() == 0) then return; end

      repeat
        TurtleCraft.import('ui/views/notification')
          .show('Recovering...\nPress Q to cancel');
        local key = IO.readKey(30);
      until (key == false or key == keys.q);

      if (key == false) then
        TurtleCraft.import('ui/views/notification')
          .show('Recovering\nLast Session');
        pvt.recoverTasks();
      end
      Recovery.reset();
    end,

    reset = function()
      log.info('Recovery.reset');

      fs.open(taskFile, 'w');
      tasks = {};
      position = fs.open(positionFile, 'w');
      location.x = 0; location.y = 0; location.z = 0; location.f = 0;
    end
  };

  ----------------------> Location Stuff
  location = {x=0,y=0,z=0,f=0};
  setmetatable(Recovery.location, {
    __index = location,
    __newindex = function() return; end,
  });

  pvt = {
    processForward = function()
      if (location.f == 0) then location.y = location.y + 1; end
      if (location.f == 1) then location.x = location.x + 1; end
      if (location.f == 2) then location.y = location.y - 1; end
      if (location.f == 3) then location.x = location.x - 1; end
    end,

    processDown = function()
      location.z = location.z - 1;
    end,

    processUp = function()
      location.z = location.z + 1;
    end,

    processRight = function()
      location.f = (location.f + 1) % 4;
    end,

    processLeft = function()
      location.f = (location.f - 1) % 4;
    end,

    cleanPosition = function()
      if (location.x ~= 0 or location.y ~= 0 or location.z ~= 0 or location.f ~= 0) then return; end
      position.close();
      position = fs.open(positionFile, 'w');
    end,

    ----------------------> Recovery Stuff
    readTasks = function()
      log.info('Recovery.readTasks');

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
        line = file.readLine();
      end
      file.close();
      return items;
    end,

    recoverPosition = function()
      log.info('Recovery.recoverPosition');

      if (not fs.exists(positionFile)) then return; end
      local recovery = fs.open(positionFile, 'r');
      local cmd = recovery.readLine();
      while (cmd) do
        if (cmd == 'forward') then pvt.processForward(); end
        if (cmd == 'up') then pvt.processUp(); end
        if (cmd == 'down') then pvt.processDown(); end
        if (cmd == 'left') then pvt.processLeft(); end
        if (cmd == 'right') then pvt.processRight(); end

        if (cmd:find('^location %d+ %d+ %d+ %d$')) then
          local values = cmd:gmatch('%d+');
          location.x = tonumber(values());
          location.y = tonumber(values());
          location.z = tonumber(values());
          location.f = tonumber(values());
        end
        cmd = recovery.readLine();
      end
      recovery.close();
      position = fs.open(positionFile, 'w');
      position.writeLine('location ' .. location.x .. ' ' .. location.y .. ' ' .. location.z .. ' ' .. location.f);
    end,

    recoverTasks = function()
      log.info('Recovery.recoverTasks');

      if (not fs.exists(taskFile)) then return; end
      local recovery = pvt.readTasks();
      local file = fs.open(taskFile, 'w');
      for _, task in ipairs(recovery) do
        file.writeLine(task);
      end
      file.close();

      for _, task in ipairs(recovery) do
        pvt.exec(task);
      end
    end,

    exec = function(cmd)
      log.info('Recovery.exec', cmd);

      local parts = cmd:gmatch('[^%s]+');
      local module = parts();
      local method = parts();
      local values = {};
      local value = parts();
      while (value) do
        if (value:match('^%d+%.%d+$') or value:match('^%d+$')) then value = tonumber(value);
        elseif (value:upper() == 'TRUE') then value = true;
        elseif (value:upper() == 'FALSE') then value = false; end
        table.insert(values, value);
        value = parts();
      end
      local lib = TurtleCraft.import(module);
      local func = lib[method];
      func(table.unpack(values));
    end,

    ----------------------> Dig Stuff
    digDetect = function(digMethod, detectMethod)
      log.info('Recovery.digDetect');

      return pvt.retry(function()
        if (not detectMethod()) then return true; end
        digMethod();
        return not detectMethod();
      end, config.maxDigs);
    end,

    digMove = function(detectMethod, digMethod, attackMethod, moveMethod)
      log.info('Recovery.digMove');

      return pvt.retry(function()
        if (not pvt.digDetect(detectMethod, digMethod)) then return false; end
        attackMethod();
        return moveMethod();
      end, config.maxAttacks);
    end,

    ---------------------->Other Stuff
    retry = function(method, max)
      log.info('Recovery.retry');

      for tries = 1, max do
        if (method()) then return true; end
      end
      return false;
    end,

    navigateTo = function(methodName, forwardMethod, upMethod, downMethod, x, y, z)
      log.info('Recovery.navigateTo', methodName, x, y, z);

      Recovery.start('services/recovery', methodName, x, y, z);
      for i = 1, 3 do
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
  }


  return Recovery;
end);
