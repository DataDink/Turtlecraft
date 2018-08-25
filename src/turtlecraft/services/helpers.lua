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
      turtle.select(1);
      return turtle.getFuelLevel() >= required;
    end,

    consolidate = function()
      for target = 1, 15 do
        turtle.select(target);
        for search = target + 1, 16 do
          local somethingToMove = turtle.getItemCount(search) > 0;
          local canMove = (somethingToMove and turtle.getItemCount(target) == 0);
          local canFill = (somethingToMove and turtle.compareTo(search));
          if (canMove or canFill) then
            turtle.select(search);
            turtle.transferTo(target);
            turtle.select(target);
          end
        end
      end
      turtle.select(1);
      for search = 1, 16 do
        if (turtle.getItemCount(search) == 0) then return true; end
      end
      return false;
    end,

    unload = function()
      -- Drop non-fuel
      local inventory = Helpers.getItemMap();
      for slot = 1, 16 do
        if (turtle.getItemCount(slot) > 0 and not inventory[slot].fuel) then
          repeat
            turtle.select(slot);
          until (turtle.getItemCount() == 0 or turtle.drop());
        end
      end
      Helpers.consolidate();
      -- Drop all but primary fuel
      for slot = 2, 16 do
        if (turtle.getItemCount(slot) > 0) then
          repeat
            turtle.select(slot);
          until (turtle.getItemCount() == 0 or turtle.drop());
        end
      end
      turtle.select(1);
    end
  };

  return Helpers;
end);
