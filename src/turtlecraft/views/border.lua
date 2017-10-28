TurtleCraft.export('views/border', function()
  local config = TurtleCraft.import('config');
  local IO = TurtleCraft.import('services/io');
  return {
    show = function()
      IO.printCentered('TurtleCraft v' .. config.version)
    end
  };
end)
