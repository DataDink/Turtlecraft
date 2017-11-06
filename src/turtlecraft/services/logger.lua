TurtleCraft.export('services/logger', function()
  local config = TurtleCraft.import('services/config');
  fs.delete(config.logsPath); -- per session

  local function write(path, level, ...)
    local args = table.pack(...);
    for i, v in ipairs(args) do args[i] = tostring(v); end

    local success, err = pcall(function()
      if (config.logsLevel > level) then return; end
      path = path or 'general.log';
      path = config.logsPath .. '/' .. path:gsub('^[%s/]+', '');
      local msg = tostring(os.time()) .. '::' .. table.concat(args, ',');
      local file = fs.open(path, 'a');
      file.writeLine(msg);
      file.close();
    end);

    if (not success) then
      print('logger failed');
      print(e);
    end
  end

  return {
    to = function(path)
      return {
        info = function(...) write(path, 0, ...); end,
        warn = function(...) write(path, 1, ...); end,
        error = function(...) write(path, 2, ...); end
      };
    end,

    info = function(...) write(nil, 0, ...); end,
    warn = function(...) write(nil, 1, ...); end,
    error = function(...) write(nil, 2, ...); end
  }
end);
