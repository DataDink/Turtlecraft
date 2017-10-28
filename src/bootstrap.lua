(function()
  if (os.getComputerLabel() == nil) then os.setComputerLabel('TurtleCraft'); end

  TurtleCraft.start();
  local plugins = TurtleCraft.import('services/plugins');
  local menu = TurtleCraft.import('ui/menu');

  local exitItem = {title='Exit TurtleCraft'};
  local items = {};

  for _, item in ipairs(plugins.list()) do
    table.insert(items, item);
  end
  table.insert(items, exitItem);

  repeat
    local selection = menu.show(items, function(i) return i.title; end);
    if (type(selection.start) == 'function') then selection.start(); end
  until (selection == exitItem);

  term.clear();
  term.setCursorPos(1,1);
  print('TurtleCraft exited');
end)()
