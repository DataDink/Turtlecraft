-- Recovery
-- Provides simple recovery functionality
-- Use in place of normal turtle movement functions
-- Coordinates and facing based on / relative to initial placement or last .reset()

-- Recovery.location              :: The turtles current location
-- Recovery.forward()             :: moves the turtle forward
-- Recovery.up()                  :: moves the turtle up
-- Recovery.down()                :: moves the turtle down
-- Recovery.face(d)               :: 0 = forward, 1 = right, 2 = backward, 3 = left
-- Recovery.left()                :: turns the turtle left
-- Recovery.right()               :: turns the turtle right
-- Recovery.start(...)            :: starts a recovery command that will be restarted if interrupted
--                                :: format: <module name> <method name> <param a> <param b> ...
--                                :: example: Recovery.start("services/recovery moveTo 12 15 22")
-- Recovery.finish()              :: completes the previously started recovery command so that it will not be re-initiated after an interruption
-- Recovery.reset()               :: sets the current turtle location and facing coordinates to 0,0,0,0


TurtleCraft.export('services/recovery', function()
  local Recovery, location, pvt;
  local config = TurtleCraft.import('services/config');
  local log = TurtleCraft.import('services/logger').to('recoverysvc.log');
  local IO = TurtleCraft.import('services/io');
  local positionFile = config.recoveryPath .. '/position.dat';
  local position = fs.open(positionFile, 'a');
  local taskFile = config.recoveryPath .. '/tasks.dat';
  local tasks = {};

  Recovery = {
    location = {},

    right = function()
      turtle.turnRight();
      position.writeLine('right');
      position.close();
      position = fs.open(positionFile, 'a');
      pvt.processRight();
      pvt.cleanPosition();
      return true;
    end,

    left = function()
      turtle.turnLeft();
      position.writeLine('left');
      position.close();
      position = fs.open(positionFile, 'a');
      pvt.processLeft();
      pvt.cleanPosition();
      return true;
    end,

    face = function(direction)
      log.info('Recovery.face', direction);

      local turns = (direction % 4) - location.f;
      if (turns == 0) then return true; end;
      if (turns > 2) then turns = -1; end
      if (turns < -2) then turns = 1; end
      local method = (turns > 0) and Recovery.right or Recovery.left;
      for i=1, math.abs(turns) do
        method();
      end
      return true;
    end,

    forward = function()
      if (not turtle.forward()) then return false; end
      position.writeLine('forward');
      position.close();
      position = fs.open(positionFile, 'a');
      pvt.processForward();
      pvt.cleanPosition();
      return true;
    end,

    up = function()
      if (not turtle.up()) then return false; end
      position.writeLine('up');
      position.close();
      position = fs.open(positionFile, 'a');
      pvt.processUp();
      pvt.cleanPosition();
      return true;
    end,

    down = function()
      if (not turtle.down()) then return false; end
      position.writeLine('down');
      position.close();
      position = fs.open(positionFile, 'a');
      pvt.processDown();
      pvt.cleanPosition();
      return true;
    end,

    start = function(...)
      log.reset();
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
        position.close();
        position = fs.open(positionFile, 'a');
      end
    end,

    recover = function()
      log.reset();
      log.info('Recovery.recover');

      local success, err = pcall(function()
        pvt.recoverPosition();
        if (#pvt.readTasks() == 0) then return; end
        TurtleCraft.import('ui/views/notification')
          .show('Recovering\nLast Session');
        pvt.recoverTasks();
      end);

      if (not success) then
        log.error(err);
        TurtleCraft.import('ui/dialog').show('Recovery Failed!');
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
      location.x = 0; location.y = 0; location.z = 0; location.f = 0;
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
        log.info(cmd, location.x, location.y, location.z, location.f);
        cmd = recovery.readLine();
      end
      recovery.close();
      position = fs.open(positionFile, 'w');
      position.writeLine('location ' .. location.x .. ' ' .. location.y .. ' ' .. location.z .. ' ' .. location.f);
      position.close();
      position = fs.open(positionFile, 'a');
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
        if (value:match('^-?%d+%.%d+$') or value:match('^-?%d+$')) then value = tonumber(value);
        elseif (value:upper() == 'TRUE') then value = true;
        elseif (value:upper() == 'FALSE') then value = false; end
        table.insert(values, value);
        value = parts();
      end
      local lib = TurtleCraft.import(module);
      local func = lib[method];
      func(table.unpack(values));
    end
  }


  return Recovery;
end);
