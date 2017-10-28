(function()
  local JSON = TurtleCraft.import('services/json');
  local config = TurtleCraft.import('services/config');

  JSON.parse(JSON.format(config));
  print(JSON.format(config));
end)()
