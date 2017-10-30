TurtleCraft.export('ui/views/select', function()
  local IO = TurtleCraft.import('services/io');
  local border = TurtleCraft.import('ui/views/border');
  return {
    show = function(items, index)
      local w, h = term.getSize();
      w = w - 2; h = h - 3; -- for border and footer

      local itemStart = math.max(1, index - math.ceil(h/2));
      itemStart = math.min(#items - h, itemStart);
      itemStart = math.max(1, itemStart);

      local lineCount = math.min(#items - itemStart, h);

      term.clear();
      for line = 2, lineCount + 2 do
        term.setCursorPos(2, line);
        local itemIndex = itemStart + (line - 2);
        local item = items[itemIndex];
        if (itemIndex == index) then term.write('>'); else term.write(' '); end
        term.write(item);
      end
      border.show();
      IO.centerLine('-use up/down/enter-', nil, h + 3);
    end
  }
end);
