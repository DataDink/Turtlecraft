TurtleCraft.export('plugins/tunnel', function()
  local Tunnel, pvt;
  local Recovery = TurtleCraft.import('services/recovery');
  local Helpers = TurtleCraft.import('services/helpers');
  local config = TurtleCraft.import('services/config');
  local log = TurtleCraft.import('services/logger');

  Tunnel = {
    start = function()

    end,

    frame = function(options)

    end,

    chamber = function()

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
      local map = Helpers.getItemMap();
      for slot = 1, 16 do
        if (map[slot].count > 1 and not map[slot].fuel) then
          turtle.select(slot);
          return true;
        end
        return false;
      end
    end,

    buildFrame = function(walls)

    end
  }

  return Tunnel;
end).onready(function()
  print('tunnel disabled');
--  TurtleCraft.import('services/plugins').register(
--    'Tunnel',
--    function()
--      TurtleCraft.import('plugins/tunnel').start();
--    end);
end)
