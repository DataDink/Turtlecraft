TurtleCraft.export('services/menu', function()
  local view = TurtleCraft.import('views/menu');
  local IO = TurtleCraft.import('services/io');
  return {
    show = function(items, transform)
      local index = 1;
      local transformed = {};
      for _, v in ipairs(items) do
        local display = transform and transform(v) or v;
        if (type(display) ~= 'string') then error('Menu items must be transformed to strings'); end
        table.insert(transformed, display);
      end

      repeat
        view.show(transformed, index);
        local key = IO.readKey();
        if (key == keys.up) then index = math.max(1, index - 1); end
        if (key == keys.down) then index = math.min(#transformed, index + 1) end
      until (key == keys.enter or key == keys.numPadEnter)

      return items[index];
    end
  };
end);
