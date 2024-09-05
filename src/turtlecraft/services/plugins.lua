TurtleCraft.export('services/plugins', function()
  local Plugins, register, sort;

  Plugins = {
    list = function()
      local sorted = sort(
        register,
        function(r) return r.order; end,
        function(grouped) return sort(
          grouped,
          function(i) return i.title; end
        ); end
      );
      local items = {};
      for _, v in ipairs(sorted) do
        table.insert(items, {title=v.title,start=v.start});
      end
      return items;
    end,

    register = function(title, start, order)
      local usage = 'Usage: TurtleCraft.import("services/plugins").register(<title>, <start function>, <optional order>);';
      if (type(start) ~= 'function') then error(usage); end
      if (type(title) ~= 'string') then error(usages); end
      if (order ~= nil and type(order) ~= 'number') then error(usage); end
      title = title:gsub('^%s+', ''):gsub('%s+$', '');
      order = order or 0;
      for _, v in ipairs(register) do
        if (title:lower() == v.title:lower()) then error('Plugin "' .. title .. '" already registered!'); end
      end
      table.insert(register, {title=title, start=start, order=order});
    end,
  };

  register = {};

  sort = function(array, by, next)
    local grouped = {};
    for _, v in ipairs(array) do
      local key = by(v);
      if (grouped[key] == nil) then grouped[key] = {}; end
      table.insert(grouped[key], v);
    end

    local sorted = {};
    for k in pairs(grouped) do
      table.insert(sorted, k);
    end
    table.sort(sorted);

    local result = {};
    for _, k in ipairs(sorted) do
      if (next and #grouped[k] > 0) then grouped[k] = next(grouped[k]); end
      for _, v in ipairs(grouped[k]) do
        table.insert(result, v);
      end
    end

    return result;
  end

  return Plugins;
end);
