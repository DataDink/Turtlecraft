TurtleCraft.export('ui/dialog', function()
  local IO = TurtleCraft.import('services/io');
  local view = TurtleCraft.import('ui/views/notification');

  return {
    show = function(text)
      view.show(text);
      IO.readKey();
    end
  };
end);
