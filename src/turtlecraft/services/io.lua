TurtleCraft.export('services/io', function()
  local IO;

  IO = {
    readKey = function(timeout)
      if (timeout) then os.startTimer(timeout); end
      local event, code, held;
      repeat
        event, code, held = os.pullEvent();
      until (event == "key" or event == "timer");
      if (event == "timer") then return false, false; end
      return code, held;
    end,

    setCancelKey = function(code, func)
      parallel.waitForAny(func, function()
        repeat
          local _, input = os.pullEvent('key');
        until (input == code);
      end);
    end,

    centerLine = function(text, fill, line)
      if (line == nil) then
        _, line = term.getCursorPos();
      end
      local width = term.getSize();
      local inset = math.ceil(width/2 - text:len()/2) + 1;
      if (inset < 0) then
        term.setCursorPos(1, line);
        term.write(text:sub(math.abs(inset) + 1, inset - 1));
        return;
      end
      if (fill ~= nil) then
        term.setCursorPos(1, line);
        term.write(fill:rep(width));
      end
      term.setCursorPos(inset, line);
      term.write(text);
    end,

    centerPage = function(text, fill)
      local lines = {};
      for line in text:gmatch('[^\n]+') do
        table.insert(lines, line);
      end
      local lineCount = #lines;
      local _, height = term.getSize();
      local start = math.floor(height/2-lineCount/2);
      for i = 1, lineCount do
        IO.centerLine(lines[i], fill, start + i);
      end
    end,

    wordWrap = function(text, width)
      local lines = {};
      local line = '';
      for block in text:gmatch('[^\n]*\n?') do
        block = block:gsub('\n', '');
        for part in block:gmatch('[^%s]+%s*') do
          if ((line .. part):len() > width) then
            table.insert(lines, line);
            line = '';
          end
          line = line .. part;
        end
        if (line:len() > 0 or block:len() == 0) then
          table.insert(lines, line);
          line = '';
        end
      end
      return table.concat(lines, '\n'), lines;
    end,

    writeBlock = function(text, left, top)
      for line in text:gmatch('[^\n]*\n?') do
        term.setCursorPos(left, top);
        term.write(line);
        top = top + 1;
      end
    end
  }

  return IO;

end);
