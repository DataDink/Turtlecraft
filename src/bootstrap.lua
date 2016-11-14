(function(locator)
  -- System
  locator["config"] = TurtleCraft.Config;
  locator["utils"] = TurtleCraft.Services.Utils;
  locator["resume"] = TurtleCraft.Services.Resume.new();
  locator["menu"] = TurtleCraft.Services.Menu.new(locator["config"], locator["utils"]);
  locator["application"] = function() return TurtleCraft.new(locator["menu"], locator["resume"], locator["position"]); end;

  -- Modules
  locator["modules"] = {};
  for _, module in TurtleCraft.Modules do
    table.insert(locator["modules"], module(locator));
  end
end)(TurtleCraft.Services.Locator.new());
