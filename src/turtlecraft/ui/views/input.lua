TurtleCraft.export('ui/views/input', function()
  local IO = TurtleCraft.import('services/io');
  local border = TurtleCraft.import('ui/views/border');

  return {
    show = function(text)
      term.clear();
      local w, h = term.getSize();
      local wrapped = IO.wordWrap(text, w - 4);
      IO.writeBlock(wrapped, 3, 3);
      term.setCursorPos(1, h - 2);
      term.clearLine();
      term.setCursorPos(1, h - 1);
      term.clearLine();
      border.show();
      term.setCursorPos(3, h - 2);
    end
  }
end);
