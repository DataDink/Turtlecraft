TurtleCraft.export('plugins/excavate', function()
  local Recovery = TurtleCraft.import('services/recovery');
  local UserInput = TurtleCraft.import('ui/user-input');
  local Excavate = {};

  Excavate = {
    ask = function(question)
      local value = UserInput.show(question .. '\n(nothing to cancel)');
      while (not value:find('^%d+$')) do
        if (value:len() == 0) then return nil; end
        value = UserInput.show(question .. '\n(please enter positive a number)');
      end
      return tonumber(value);
    end,

    start = function()
      local forward = Excavate.ask('How far forward should I dig?');
      if (forward == nil) then return; end

      local left = Excavate.ask('How far to the left should I dig?');
      if (left == nil) then return; end

      local right = Excavate.ask('How far to the right should I dig?');
      if (right == nil) then return; end

      local up = Excavate.ask('How far up should I dig?');
      if (up == nil) then return; end

      local down = Excavate.ask('How far down should I dig?');
      if (down == nil) then return; end

      Excavate.recover(forward, left, right, up, down);
    end,

    recover = function(forward, left, right, up, down, recovered)
      forward = math.abs(forward);
      left = -math.abs(left);
      right = math.abs(right);
      up = math.abs(up);
      down = -math.abs(down);
      local dispose = Recovery.onStep(Excavate.step);

      if (not recovered) then
        Recovery.reset();
        Recovery.start('plugins/excavate recover ' .. forward .. ' ' .. -left .. ' ' .. right .. ' ' .. up .. ' ' .. -down .. ' true');
        Recovery.digTo(left, 0, up - 1);
      end

      local function doRow()
        if (Recovery.location.x < right) then
          Recovery.excavateTo(right, Recovery.location.y, Recovery.location.z);
        else
          Recovery.excavateTo(left, Recovery.location.y, Recovery.location.z);
        end
      end

      local function doLayer()
        if (Recovery.location.y > 0) then
          while (Recovery.location.y > 0) do
            doRow();
            Recovery.excavateTo(Recovery.location.x, Recovery.location.y - 1, Recovery.location.z);
          end
        else
          while (Recovery.location.y < forward) do
            doRow();
            Recovery.excavateTo(Recovery.location.x, Recovery.location.y + 1, Recovery.location.z);
          end
        end
      end

      while (Recovery.location.z > down) do
        doLayer();
        Recovery.excavateTo(Recovery.location.x, Recovery.location.y, Recovery.location.z - 1);
      end

      Recovery.finish();
      dispose();
      Recovery.digTo(0,0,0);
    end,

    step = function()
      Excavate.checkFuel();
      Excavate.checkInventory();
    end,

    checkFuel = function()

    end,

    checkInventory = function()

    end
  };

  return Excavate;
end).onready(function()
  TurtleCraft.import('services/plugins').register(
    'Excavate',
    function()
      TurtleCraft.import('plugins/excavate').start();
    end
  )
end);
