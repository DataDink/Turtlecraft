TurtleCraft.export('services/helpers', function()
  local Helpers;
  local config = TurtleCraft.import('services/config');

  local fuelMap = {};
  for _, name in ipairs(config.fuelItems) do fuelMap[name] = true; end

  Helpers = {
    getItemMap = function()
      local map = {};
      for slot = 1, 16 do
        local item = {};
        item.count = turtle.getItemCount(slot);
        item.name = item.count > 0 and turtle.getItemDetail(slot).name;
        item.fuel = item.name and fuelMap[item.name];
        table.insert(map, item);
      end
      return map;
    end,

    refuel = function(required)
      required = required or 1;
      if (turtle.getFuelLevel() > required) then return true; end
      local inventory = Helpers.getItemMap();
      local scan = {};
      for slot = 1, 16 do if (inventory[slot].fuel) then table.insert(scan, slot); end end
      for slot = 1, 16 do if (not inventory[slot].fuel) then table.insert(scan, slot); end end
      for _, slot in ipairs(scan) do
        while (turtle.getItemCount(slot) > 0 and turtle.getFuelLevel() < required) do
          turtle.select(slot);
          if (not turtle.refuel(1)) then break; end
        end
      end
      return turtle.getFuelLevel() >= required;
    end,

    consolidate = function()
      for search = 2, 16 do
        for target = 1, search - 1 do
          while (turtle.getItemCount(search) > 0) do
            turtle.select(search);
            turtle.transferTo(target);
          end
        end
      end
      for search = 1, 16 do
        if (turtle.getItemCount(search) == 0) then return true; end
      end
      return false;
    end,

    unload = function()
      local inventory = Helpers.getItemMap();
      for slot = 1, 16 do
        if (turtle.getItemCount(slot) > 0 and not inventory[slot].fuel) then
          repeat
            turtle.select(slot);
          until (turtle.getItemCount() == 0 or turtle.drop());
        end
      end
      Helpers.consolidate();
      for slot = 2, 16 do
        if (turtle.getItemCount(slot)) then
          repeat
            turtle.select(slot);
          until (turtle.getItemCount() == 0 or turtle.drop());
        end
      end
    end
  };

  return Helpers;
end);
