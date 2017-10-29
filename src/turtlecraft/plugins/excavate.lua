TurtleCraft.export('plugins/excavate', function()
  local Excavate, pvt;
  local Recovery = TurtleCraft.import('services/recovery');
  local UserInput = TurtleCraft.import('ui/user-input');
  local config = TurtleCraft.import('services/config');

  Excavate = {
    start = function()
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
      forward = math.abs(forward);
      left = -math.abs(left);
      right = math.abs(right);
      up = math.abs(up);
      down = -math.abs(down);

      if (not recovered) then
        Recovery.start('plugins/excavate', 'recover', forward, -left, right, up, -down, true);
        Recovery.digTo(left, 0, up - 1);
      end

      local function row()
        local direction = Recovery.location.x < right and 1 or -1;
        local distance = math.abs(Recovery.location.x - (direction == 1 and right or left));
        for i = 1, distance do
          if (direction == 1) then Recovery.face(1); else Recovery.face(3); end
          pvt.checkFuel(2);
          pvt.checkInventory();
          if (not Recovery.excavateForward()) then return false; end
        end
        return true;
      end

      local function plane()
        local direction = Recovery.location.y < forward and 1 or -1;
        local distance = math.abs(Recovery.location.y - (direction == 1 and forward or 0));
        for i = 1, distance do
          if (not row()) then return false; end
          if (direction == 1) then Recovery.face(0); else Recovery.face(2); end
          if (not Recovery.excavateForward()) then return false; end
        end
        return true;
      end

      local function block()
        local distance = math.max(0, Recovery.location.z - down);
        for i = 1, distance do
          if (not plane()) then return false; end
          if (not Recovery.excavateDown()) then return false; end
        end
        return true;
      end

      block();

      Recovery.finish();
      Recovery.digTo(0,0,0);
    end,

    refuel = function(required, x, y, z, recovered)
      if (not recovered) then
        Recovery.start('plugins/excavate', 'refuel', x, y, z, required, true);
      end
      Recovery.digTo(0,0,0);

      while (turtle.getFuelLevel() < required) do
        TurtleCraft.import('ui/dialog')
                   .show('I need more fuel!\nPlease put some in\nmy inventory and\npress any key');
        pvt.seekFuel(required);
      end

      Recovery.digTo(x, y, z);
      Recovery.finish();
    end,

    empty = function(x, y, z, recovered)
      if (not recovered) then
        Recovery.start('plugins/excavate', 'empty', x, y, z, true);
      end
      Recovery.digTo(0,0,0);
      Recovery.face(2);
      for slot = 1, 16 do
        local info = turtle.getItemDetail(slot);
        if (info and not pvt.isFuelItem(info)) then
          turtle.select(slot);
          repeat
            turtle.select(slot);
          until (turtle.getItemCount() == 0 or turtle.drop());
        end
      end
      pvt.consolidate();
      Recovery.digTo(x, y, z);
      Recovery.finish();
    end
  };

  pvt = {
    ask = function(question)
      local value = UserInput.show(question .. '\n(nothing to cancel)');
      while (not value:find('^%d+$')) do
        if (value:len() == 0) then return nil; end
        value = UserInput.show(question .. '\n(please enter positive a number)');
      end
      return tonumber(value);
    end,

    checkFuel = function(required)
      if (turtle.getFuelLevel() == 'unlimited') then return; end
      required = required or 0;
      required = required * 2; -- there and back
      required = required + math.abs(Recovery.location.x);
      required = required + math.abs(Recovery.location.y);
      required = required + math.abs(Recovery.location.z);
      if (turtle.getFuelLevel() < required and not pvt.seekFuel(required)) then
        Excavate.refuel(required, Recovery.location.x, Recovery.location.y, Recovery.location.z);
      end
    end,

    seekFuel = function(required)
      local overdose = math.min(turtle.getFuelLimit(), required + 1000);
      for slot = 1, 16 do
        if (turtle.getSlotCount(slot) > 0) then
          while ((turtle.getFuelLevel() < overdose and turtle.refuel(1)) do end
          if (turtle.getFuelLevel() >= overdose) then return true; end
        end
      end
      return false;
    end,

    checkInventory = function()
      for i = 1, 2 do
        for slot = 1, 16 do
          if (turtle.getItemCount(slot) == 0) then return; end
        end
        pvt.consolidate();
      end
      Excavate.empty(Recovery.location.x, Recovery.location.y, Recovery.location.z);
    end,

    isFuelItem = function(info)
      if (not info.id and not info.id:find('^%d+')) then return false; end
      local itemId = tonumber(info.id:match('^%d+'));
      for _, fuelId in ipairs(config.fuelItems) do
        if (fuelId == itemId) then return true; end
      end
      return false;
    end,

    consolidate = function()
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
