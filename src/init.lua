TurtleCraft = {};

(function()
  local modules = {};
  TurtleCraft.export = function(name, module)
    if (modules[name] ~= nil) then error('module ' .. name .. ' exists'); end
    local resolved = type(module) ~= 'function';
    modules[name] = {resolved = resolved, value = module};
  end
  TurtleCraft.import = function(name)
    if (not modules[name]) then error('module ' .. name .. ' does not exist.'); end
    if (not modules[name].resolved) then
      modules[name].value = modules[name].value();
      modules[name].resolved = true;
    end
    return modules[name].value;
  end
end)();
