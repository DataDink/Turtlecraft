(function()
  local menu = TurtleCraft.import('services/menu');

  local item = menu.show({
    {title = 'item 1'},
    {title = 'item 2'},
    {title = 'item 3'},
    {title = 'item 4'},
  }, function(i) return i.title; end);

  term.setCursorPos(1,1);
  term.write(item.title);
end)()
