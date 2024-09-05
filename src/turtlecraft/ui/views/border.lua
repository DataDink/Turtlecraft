TurtleCraft.export('ui/views/border', function()
  local config = TurtleCraft.import('services/config');
  local IO = TurtleCraft.import('services/io');
  return {
    show = function()
      local w, h = term.getSize();
      IO.centerLine('TurtleCraft v' .. config.version .. ' ' .. config.env, '=', 1);
      for l = 2, h do
        term.setCursorPos(1, l);
        term.write('|');
        term.setCursorPos(w, l);
        term.write('|');
      end
      term.setCursorPos(1, h);
      term.write(('='):rep(w));
    end
  };
end);
