TurtleCraft.export('ui/views/notification', function()
  local border = TurtleCraft.import('ui/views/border');
  local IO = TurtleCraft.import('services/io');
  return {
    show = function(message)
      term.clear();
      IO.centerPage(message);
      border.show();
    end
  };
end);
