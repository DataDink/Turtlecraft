(function()
  local JSON = TurtleCraft.import('services/json');
  local config = TurtleCraft.import('services/config');
  print(JSON.format(config));
end)()
