(function()
  local plugins = TurtleCraft.import('services/plugins');
  plugins.register('first', function() end, 0);
  plugins.register('second', function() end, -1);
  plugins.register('third', function() end, 0);
  plugins.register('fourth', function() end, -1);

  local result = plugins.list();
  for _, v in ipairs(result) do
    print(v.title);
  end
end)()
