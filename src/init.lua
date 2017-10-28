local TurtleCraft = {};

(function()
  local modules = {};
  local startup = {};
  TurtleCraft.export = function(name, module)
    if (modules[name] ~= nil) then error('module ' .. name .. ' exists'); end
    local resolved = type(module) ~= 'function';
    modules[name] = {resolved = resolved, value = module};
    return {
      onready = function(callback)
        if (type(callback) ~= 'function') then error('callback must be a function'); end
        table.insert(startup, callback);
      end
    };
  end
  TurtleCraft.import = function(name)
    if (not modules[name]) then error('module ' .. name .. ' does not exist.'); end
    if (not modules[name].resolved) then
      modules[name].value = modules[name].value();
      modules[name].resolved = true;
    end
    return modules[name].value;
  end
  TurtleCraft.start = function()
    if (startup == false) then  error('TurtleCraft started twice!'); end
    for _, callback in ipairs(startup) do
      callback();
    end
    startup = false;
  end
end)();
