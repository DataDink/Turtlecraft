TurtleCraft.export('plugins/excavate', function()
  local Excavate, pvt;
  local IO = TurtleCraft.import('services/io');
  local Recovery = TurtleCraft.import('services/recovery');
  local UserInput = TurtleCraft.import('ui/user-input');
  local config = TurtleCraft.import('services/config');
  local log = TurtleCraft.import('services/logger');

  Excavate = {
    start = function()
      log.info('Excavate.start');

      local forward = pvt.ask('How far forward should I dig?');
      if (forward == nil) then return; end

      local left = pvt.ask('How far to the left should I dig?');
      if (left == nil) then return; end

      local right = pvt.ask('How far to the right should I dig?');
      if (right == nil) then return; end

      local up = pvt.ask('How far up should I dig?');
      if (up == nil) then return; end

      local down = pvt.ask('How far down should I dig?');
      if (down == nil) then return; end

      Recovery.reset();
      Excavate.recover(forward, left, right, up, down);
    end,

    recover = function(forward, left, right, up, down, recovered)
      log.info('Excavate.recover', left, right, up, down, recovered);

      forward = math.abs(forward);
      left = -math.abs(left);
      right = math.abs(right);
      up = math.abs(up);
      down = -math.abs(down);

      if (not recovered) then
        if (not pvt.checkFuel(-left + up)) then return false; end
        Recovery.start('plugins/excavate', 'recover', forward, -left, right, up, -down, true);
        Recovery.digTo(left, 0, up - 1);
      end

      local function row()
        local direction = Recovery.location.x < right;
        local complete = direction
          and (function() return Recovery.location.x >= right; end)
           or (function() return Recovery.location.x <= left; end);
        repeat
          pvt.showUpdate((up - Recovery.location.z) / (up - down));
          if (direction)
            then Recovery.face(1);
            else Recovery.face(3);
          end
          if (not Recovery.excavateForward()) then return false; end
          if (pvt.checkFuel(4) == false) then return false; end
          pvt.checkInventory();
        until (complete())
        return true;
      end

      local function plane()
        local direction = Recovery.location.y < forward;
        local complete = direction
          and (function() return Recovery.location.y >= forward; end)
           or (function() return Recovery.location.y <= 0 end);
        repeat
          if (not row()) then return false; end
          if (direction)
            then Recovery.face(0);
            else Recovery.face(2);
          end
          if (not Recovery.excavateForward()) then return false; end
        until (complete())
        return true;
      end

      local function block()
        repeat
          if (not plane()) then return false; end
          if (not Recovery.excavateDown()) then return false; end
          for i = 1, 2 do
            if (not Recovery.excavateDown()) then
              if (not plane()) then return false; end
              return false; 
            end
          end
        until (Recovery.location.z < (down - 1))
        return true;
      end

      IO.setCancelKey(keys.q, block)

      TurtleCraft.import('ui/views/notification').show('Coming Home!');

      Recovery.finish();
      Recovery.digTo(0,0,0);
      pvt.unload();
      Recovery.reset();
    end,

    refuel = function(required, x, y, z, recovered)
      log.info('Excavate.refuel', required, x, y, z, recovered);

      if (not recovered) then
        Recovery.start('plugins/excavate', 'refuel', x, y, z, required, true);
      end

      local minimum = math.abs(Recovery.location.x)
                    + math.abs(Recovery.location.y)
                    + math.abs(Recovery.location.z);
      if (turtle.getFuelLevel() > minimum) then
        Recovery.digTo(0,0,0);
      end

      while (turtle.getFuelLevel() < required and not pvt.seekFuel(required)) do
        TurtleCraft.import('ui/dialog')
                   .show('Please add fuel to\nmy inventory and\npress any key');
      end

      Recovery.digTo(x, y, z);
      Recovery.finish();
      return true;
    end,

    empty = function(x, y, z, recovered)
      log.info('Excavate.empty', x, y, z, recovered);

      if (not recovered) then
        Recovery.start('plugins/excavate', 'empty', x, y, z, true);
      end
      Recovery.digTo(0,0,0);
      pvt.unload();
      Recovery.digTo(x, y, z);
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

    checkFuel = function(required)
      log.info('Excavate.checkFuel', required);

      if (turtle.getFuelLevel() == 'unlimited') then return true; end
      required = required or 0;
      required = required * 2; -- there and back
      required = required + math.abs(Recovery.location.x);
      required = required + math.abs(Recovery.location.y);
      required = required + math.abs(Recovery.location.z);
      if (turtle.getFuelLevel() <= required and not pvt.seekFuel(required)) then
        return Excavate.refuel(required, Recovery.location.x, Recovery.location.y, Recovery.location.z);
      end
      return true;
    end,

    seekFuel = function(required)
      log.info('Excavate.seekFuel', required);

      local overdose = math.min(turtle.getFuelLimit(), required + 1000);
      for slot = 1, 16 do
        if (turtle.getItemCount(slot) > 0) then
          turtle.select(slot);
          while (turtle.getFuelLevel() < overdose and turtle.refuel(1)) do end
          if (turtle.getFuelLevel() >= overdose) then return true; end
        end
      end
      return false;
    end,

    checkInventory = function()
      log.info('Excavate.checkInventory');

      for passes = 1, 2 do
        for slot = 1, 16 do
          if (turtle.getItemCount(slot) == 0) then return; end
        end
        if (passes == 1) then pvt.consolidate(); end
      end

      Excavate.empty(Recovery.location.x, Recovery.location.y, Recovery.location.z);
    end,

    isFuelItem = function(info)
      log.info('Excavate.isFuelItem');

      if (not info or not info.name) then return false; end
      for _, fuelName in ipairs(config.fuelItems) do
        if (fuelName == info.name) then return true; end
      end
      return false;
    end,

    unload = function()
      Recovery.face(2);
      for slot = 1, 16 do
        local info = turtle.getItemDetail(slot);
        if (info and not pvt.isFuelItem(info)) then
          repeat
            turtle.select(slot);
          until (turtle.getItemCount() == 0 or turtle.drop());
        end
      end
      pvt.consolidate();
      for slot = 2, 16 do
        if (turtle.getItemCount(slot) > 0) then
          repeat
            turtle.select(slot);
          until (turtle.getItemCount() == 0 or turtle.drop());
        end
      end
      Recovery.face(0);
    end,

    consolidate = function()
      log.info('Excavate.consolidate');

      for consolidate = 2, 16 do
        for slot = 1, consolidate - 1 do
          turtle.select(consolidate);
          if (turtle.transferTo(slot)) then break; end
        end
      end
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
