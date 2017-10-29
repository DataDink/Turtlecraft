TurtleCraft.export('ui/plugin-menu', function()
  local Select = TurtleCraft.import('ui/select');
  local Plugins = TurtleCraft.import('services/plugins');

  return {
    show = function(exitText)
      local exitItem = {title=exitText or 'Exit'};
      local items = {};

      for _, item in ipairs(Plugins.list()) do
        table.insert(items, item);
      end
      table.insert(items, exitItem);

      repeat
        local selection = Select.show(items, function(i) return i.title; end);
        if (type(selection.start) == 'function') then selection.start(); end
      until (selection == exitItem);
    end
  };

end);
