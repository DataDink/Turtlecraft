(function()
  local plugins = TurtleCraft.import('services/plugins');
  local menu = TurtleCraft.import('services/menu');

  local exitItem = {title='Exit TurtleCraft'};
  local items = {exitItem};

  for _, item in ipairs(plugins.list()) do
    table.insert(items, item);
  end

  repeat
    local selection = menu.show(items, function(i) return i.title; end);
    if (type(selection.start) == 'function') then selection.start(); end
  until (selection == exitItem);

  term.clear();
end)()
