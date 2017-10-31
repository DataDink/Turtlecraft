TurtleCraft.export('ui/views/progress', function()
  local IO = TurtleCraft.import('services/io');
  local border = TurtleCraft.import('ui/views/border');

  return {
    show = function(text, progress)
      term.clear();
      local w, h = term.getSize();
      local _, wrapped = IO.wordWrap(text, w - 4);
      local start = math.floor(h / 2 - #wrapped / 2);
      for line = 1, #wrapped do
        term.setCursorPos(3, line + start)
        term.write(wrapped[line]);
      end
      term.setCursorPos(3, start + #wrapped + 1);
      local length = math.floor(math.min(w-4, math.max(0, (w - 4) * progress)));
      term.write(('>'):rep(length));
      border.show();
      term.setCursorPos(1,1);
    end
  }
end);
