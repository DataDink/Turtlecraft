TurtleCraft.export('services/io', function()
  local IO = {};

  IO.readKey = function(timeout)
    if (timeout) then os.startTimer(timeout); end
    local event, code, held;
    repeat
      event, code, held = os.pullEvent();
    until (event == "key" or event == "timer");
    if (event == "timer") then return false, false; end
    return code, held;
  end

  IO.setCancelKey = function(code, func)
    parallel.waitForAny(func, function()
      local input;
      repeat
        _, input = os.pullEvent('key');
      until (input == code);
    end);
  end

  IO.centerLine = function(text, fill, line)
    if (line == nil) then
      _, line = term.getCursorPos();
    end
    local width = term.getSize();
    local inset = math.floor(width/2 - text:len()/2);
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
  end

  IO.centerPage = function(text, fill)
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
  end

  return IO;

end);
