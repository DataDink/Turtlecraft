TurtleCraft.export('services/config', function()
  -- NOTE: cfgjson will be added to the turtlecraft scope at build time
  return TurtleCraft.require('services/json').parse(cfgjson or '{}');
end)
