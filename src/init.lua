TurtleCraft = {};

(function()
  local modules = {};
  TurtleCraft.export = function(name, module)
    local resolved = type(module) ~= 'function';
    modules[name] = {resolved = resolved, value = module};
  end
  TurtleCraft.import = function(name)
    if (modules[name]) then error('module ' .. name .. ' does not exist.'); end
    if (not modules[name].resolved) then modules[name].value = modules[name].value(); end
    return modules[name].value;
  end
end)();
