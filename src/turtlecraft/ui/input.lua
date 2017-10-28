TurtleCraft.export('ui/user-input', function()
  local view = TurtleCraft.import('ui/views/input');
  return {
    show = function(text)
      view.show(text);
      return read();
    end
  }
end)
