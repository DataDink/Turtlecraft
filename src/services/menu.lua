TurtleCraft.Services.Menu = {};
TurtleCraft.Services.Menu.__index = TurtleCraft.Services.Menu;

function TurtleCraft.Services.Menu.new(config, utils)
  local self = setmetatable({}, TurtleCraft.Services.Menu);
  local items = {};
  local path = "";
  local index = 1;

  function self.register(path, action)
    items[utils.path.normalize(path)] = action;
  end

  function self.navigate(item)
    path = utils.path.normalize(path) .. utils.path.normalize(item);
    return items[path];
  end

  function self.back()
    path = utils.path.regress(path, 1);
    return items[path];
  end

  function self.init()
    while (true) do
      render();
      local _, key = os.pullEvent("key");

      local scope = getScope();
      if (key == keys.up) then
        index = math.max(1, index - 1);
      elseif (key == keys.down) then
        index = math.min(table.getn(scope), index + 1);
      elseif (key == keys.left) then
        return self.back();
      elseif (key == keys.right or key == keys.enter or key == keys.numPadEnter) then
        scope[index].action();
      end
    end
  end

  local function getScope()
    local scope = {};
    for p, a in pairs(items) do
      local select = utils.path.select(p, path);
      if (select.next) then
        if (select.remainder) then
          scope[select.next] = function() self.navigate(select.next); end
        else
          scope[select.next] = a;
        end
      end
    end

    local items = {};
    for name, action in pairs(scope) do
      table.insert(items, {name = name, action = action});
    end
    return items;
  end

  local function render()
    local scope = getScope();
    local maxIndex = table.getn(scope);

    local maxStart = maxIndex - config.maxMenuDisplay;
    local start = index - math.floor(config.maxMenuDisplay / 2);
    start = math.min(start, maxStart);
    start = math.max(1, start);
    local stop = math.min(maxIndex, start + config.maxMenuDisplay);

    term.clear();
    term.setCursorPos(1, 1);
    term.write(config.appHeader);
    term.setCursorPos(1, config.appHeaderHeight + 1);

    for itemIndex = start, stop do
      local item = scope[itemIndex];
      local isSelected = itemIndex == index;
      local display = "";
      if (isSelected) then
        display = display .. "> "
      else
        display = display .. "  "
      end
      display = display .. item.name;
      term.write(display);
    end

    term.setCursorPos(1, config.displayHeight);
    term.write("--- Use Arrow / Enter Keys");
  end
end
