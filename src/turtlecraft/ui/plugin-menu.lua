TurtleCraft.export('ui/plugin-menu', function()
  local Select = TurtleCraft.import('ui/select');
  local Dialog = TurtleCraft.import('ui/dialog');
  local Recovery = TurtleCraft.import('services/recovery');
  local Plugins = TurtleCraft.import('services/plugins');
  local log = TurtleCraft.import('services/logger');

  return {
    show = function(exitText)
      local exitItem = {title=exitText or 'Exit'};
      local items = {};

      for _, item in ipairs(Plugins.list()) do
        table.insert(items, item);
      end
      table.insert(items, exitItem);

      repeat
        Recovery.reset();
        local selection = Select.show(items, function(i) return i.title; end);
        if (type(selection.start) == 'function') then
          local success, err = pcall(selection.start);
          if (not success) then
            log.error(err);
            Dialog.show(selection.title .. ' broke!');
          end
        end
      until (selection == exitItem);
    end
  };

end);
