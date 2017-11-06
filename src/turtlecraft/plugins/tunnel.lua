TurtleCraft.export('plugins/tunnel', function()
  local Tunnel, pvt;
  local Recovery = TurtleCraft.import('services/recovery');
  local Helpers = TurtleCraft.import('services/helpers');
  local config = TurtleCraft.import('services/config');
  local log = TurtleCraft.import('services/logger');

  Tunnel = {
    start = function()

    end,

    forward = function()
      Recovery.reset();
      if (not Helpers.refuel(9)) then pvt.alertFuel(); end
      TurtleCraft.import('ui/views/notification').show('Building Forward...');
      if (not Recovery.digForward()) then return pvt.alertFailed(); end
      Recovery.turnLeft();
      if (not Recovery.excavateForward()) then
        Recovery.digTo(0,0,0);
        return alertFailed();
      end
    end
  };

  pvt = {
    alertFuel = function()
      TurtleCraft.import('ui/dialog').show('I am out of fuel!');
    end,

    alertFailed = function()
      TurtleCraft.import('ui/dialog').show('Sorry, I failed!');
    end,

    alertInventory = function()
      TurtleCraft.import('ui/dialog').show('I am out of blocks!');
    end,

    selectBlock = function()
      for slot = 1, 16 do
        if (turtle.getItemCount(slot) > 1) then
          turtle.select(slot);
          return true;
        end
        return false;
      end
    end
  }

  return Tunnel;
end).onready(function()
  TurtleCraft.import('services/plugins').register(
    'Tunnel',
    function()
      TurtleCraft.import('plugins/tunnel').start();
    end);
end)
