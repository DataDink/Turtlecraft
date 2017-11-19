TurtleCraft.export('plugins/excavate', function()
  local Excavate, pvt;
  local IO = TurtleCraft.import('services/io');
  local Recovery = TurtleCraft.import('services/recovery');
  local UserInput = TurtleCraft.import('ui/user-input');
  local Helpers = TurtleCraft.import('services/helpers');
  local config = TurtleCraft.import('services/config');
  local log = TurtleCraft.import('services/logger').to('excavate.log');

  Excavate = {
    start = function()
      log.reset();
      log.info('Excavate.start');

      local forward = pvt.ask('How far forward should I dig?');
      if (forward == nil) then return; end

      local left = pvt.ask('How far to the left should I dig?');
      if (left == nil) then return; end
      left = -left;

      local right = pvt.ask('How far to the right should I dig?');
      if (right == nil) then return; end

      local up = pvt.ask('How far up should I dig?');
      if (up == nil) then return; end

      local down = pvt.ask('How far down should I dig?');
      if (down == nil) then return; end
      down = -down;

      Recovery.reset();
      Excavate.recover(forward, left, right, up, down);
    end,

    digTo = function (x, y, z, recovered)
      if (not recovered) then Recovery.start('plugins/excavate', 'digTo', x, y, z, true); end
      local distance = math.abs(Recovery.location.x - x)
                   + math.abs(Recovery.location.y - y)
                   + math.abs(Recovery.location.z - z);
      pvt.checkFuel(distance);
      pvt.digTo(x, y, z);
      Recovery.finish();
    end,

    forward = function()
      pvt.checkFuel(1);
      while (turtle.detectUp() and turtle.digUp()) do end
      while (turtle.detectDown() and turtle.digDown()) do end
      while (not Recovery.forward()) do
        if (turtle.detect() and not turtle.dig()) then return false;
        else turtle.attack(); end
      end
    end,

    up = function()
      pvt.checkFuel(1);
      while (turtle.detectDown() and turtle.digDown()) do end
      while (not Recovery.up()) do
        if (turtle.detectUp() and not turtle.digUp()) then return false;
        else turtle.attackUp(); end
      end
      return true;
    end,

    down = function()
      pvt.checkFuel(1);
      while (turtle.detectUp() and turtle.digUp()) do end
      while (not Recovery.down()) do
        if (turtle.detectDown() and not turtle.digDown()) then return false;
        else turtle.attackDown(); end
      end
      return true;
    end,

    recover = function(forward, left, right, up, down, recovered)
      log.info('Excavate.recover', left, right, up, down, recovered);
      if (not recovered) then
        Recovery.start('plugins/excavate', 'recover', forward, left, right, up, down, true);
        Excavate.digTo(left, 0, up - 1);
      else
        Excavate.digTo(left, 0, Recovery.location.z);
      end

      forward = math.max(0, forward);
      right = math.max(left, right);
      up = math.max(down, up);

      local function row()
        local direction = Recovery.location.x < right;
        if (direction) then Excavate.digTo(left, Recovery.location.y, Recovery.location.z); end
        local complete = direction
          and (function() return Recovery.location.x >= right; end)
           or (function() return Recovery.location.x <= left; end);
        while (not complete()) do
          pvt.showUpdate((up - Recovery.location.z) / (up - down));
          if (direction)
            then Recovery.face(1);
            else Recovery.face(3);
          end
          Excavate.forward();
          pvt.checkInventory();
        end
      end

      local function plane()
        local direction = Recovery.location.y < forward;
        local complete = direction
          and (function() return Recovery.location.y >= forward; end)
           or (function() return Recovery.location.y <= 0 end);
        while (not complete()) do
          row();
          if (direction)
            then Recovery.face(0);
            else Recovery.face(2);
          end
          Excavate.forward();
        end
        row();
      end

      local function block()
        local target = down + 1;
        plane();
        while (Recovery.location.z >= target) do
          pvt.checkFuel(3);
          if (not Excavate.down()) then return; end
          if (Recovery.location.z <= target or not Excavate.down()) then return; end
          Excavate.down();
          plane();
        end
      end

      IO.setCancelKey(keys.q, block)

      TurtleCraft.import('ui/views/notification').show('Coming Home!\n(Press Q to halt)');

      IO.setCancelKey(keys.q, (function()
        Recovery.finish();
        Excavate.digTo(0,0,0);
        pvt.unload();
      end));
      Recovery.reset();
    end,

    refuel = function(required, x, y, z)
      log.info('Excavate.refuel', required, x, y, z);

      if (not x) then
        x = Recovery.location.x;
        y = Recovery.location.y;
        z = Recovery.location.z;
        Recovery.start('plugins/excavate', 'refuel', requires, x, y, z);
      end

      local minimum = math.abs(Recovery.location.x)
                    + math.abs(Recovery.location.y)
                    + math.abs(Recovery.location.z);
      if (turtle.getFuelLevel() > minimum) then
        pvt.digTo(0,0,0);
      end

      required = required + math.abs(x) + math.abs(y) + math.abs(z)
      while (turtle.getFuelLevel() < required and not pvt.seekFuel(required)) do
        TurtleCraft.import('ui/dialog')
                   .show('Please add fuel to\nmy inventory and\npress any key');
      end
      TurtleCraft.import('ui/views/notification').show('Continuing...');

      pvt.digTo(x, y, z);
      Recovery.finish();
      return true;
    end,

    empty = function(x, y, z)
      log.info('Excavate.empty', x, y, z);

      if (not x) then
        x = Recovery.location.x;
        y = Recovery.location.y;
        z = Recovery.location.z;
        Recovery.start('plugins/excavate', 'empty', x, y, z);
      end
      Excavate.digTo(0,0,0);
      pvt.unload();
      Excavate.digTo(x, y, z);
      Recovery.finish();
    end
  };

  pvt = {
    ask = function(question)
      log.info('Excavate.ask');

      local value = UserInput.show(question .. '\n(nothing to cancel)');
      while (not value:find('^%d+$')) do
        if (value:len() == 0) then return nil; end
        value = UserInput.show(question .. '\n(please enter positive a number)');
      end
      return tonumber(value);
    end,

    showUpdate = function(progress)
      local message = 'Fuel: ' .. tostring(turtle.getFuelLevel()) .. '\n'
                  .. 'Up/Down: ' .. tostring(Recovery.location.z) .. '\n'
                  .. 'Left/Right: ' .. tostring(Recovery.location.x) .. '\n'
                  .. 'Forward: ' .. tostring(Recovery.location.y) .. '\n'
                  .. '--- Press Q To Quit ---';
      TurtleCraft.import('ui/views/progress').show(message, progress);
    end,

    digTo = function(x, y, z)
      local function go(face, detect, dig, attack, move, complete)
        Recovery.face(face);
        while (not complete()) do
          if (detect() and not dig()) then return;
          elseif (not move()) then attack(); end
        end
      end
      local function goX()
        go(1, turtle.detect, turtle.dig, turtle.attack, Recovery.forward, function() return Recovery.location.x >= x; end);
        go(3, turtle.detect, turtle.dig, turtle.attack, Recovery.forward, function() return Recovery.location.x <= x; end);
      end
      local function goY()
        go(0, turtle.detect, turtle.dig, turtle.attack, Recovery.forward, function() return Recovery.location.y >= y; end);
        go(2, turtle.detect, turtle.dig, turtle.attack, Recovery.forward, function() return Recovery.location.y <= y; end);
      end
      local function goZ()
        go(0, turtle.detectUp, turtle.digUp, turtle.attackUp, Recovery.up, function() return Recovery.location.z >= z; end);
        go(0, turtle.detectDown, turtle.digDown, turtle.attackDown, Recovery.down, function() return Recovery.location.z <= z; end);
      end
      if (Recovery.location.z == 0) then goZ(); end
      goY();
      goX();
      if (Recovery.location.z ~= 0) then goZ(); end
    end,

    checkFuel = function(required)
      log.info('Excavate.checkFuel', required);

      if (turtle.getFuelLevel() == 'unlimited') then return true; end
      required = required or 0;
      required = required * 2; -- there and back
      required = required + math.abs(Recovery.location.x);
      required = required + math.abs(Recovery.location.y);
      required = required + math.abs(Recovery.location.z);
      if (turtle.getFuelLevel() <= required and not pvt.seekFuel(required)) then
        return Excavate.refuel(required);
      end
      return true;
    end,

    seekFuel = function(required)
      log.info('Excavate.seekFuel', required);
      local overdose = math.min(turtle.getFuelLimit(), required + 1000);
      return Helpers.refuel(overdose);
    end,

    checkInventory = function()
      log.info('Excavate.checkInventory');
      for slot = 1, 16 do if (turtle.getItemCount(slot) == 0) then return; end end
      if (not Helpers.consolidate()) then
        Excavate.empty();
      end
    end,

    unload = function()
      Recovery.face(2);
      Helpers.unload();
      Recovery.face(0);
    end
  }

  return Excavate;
end).onready(function()
  TurtleCraft.import('services/plugins').register(
    'Excavate',
    function()
      TurtleCraft.import('plugins/excavate').start();
    end
  )
end);
