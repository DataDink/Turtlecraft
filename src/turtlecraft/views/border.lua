TurtleCraft.export('views/border', function()
  local config = TurtleCraft.require('config');
  local IO = TurtleCraft.require('services/io');
  return {
    show = function()
      IO.printCentered('TurtleCraft v' .. config.version)
    end
  };
end)
