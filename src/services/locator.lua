TurtleCraft.Services.Locator = {
  new = function()
    local registrations = {};
    local self = setmetatable({}, {
      __newindex = function(key, value)
        if (type(value) == "function") then
          registrations[key] = value;
        else
          registrations[key] = function() return value; end;
        end
      end,
      __index = function(key)
        if (registrations[key]) then return registrations[key](); end
        return nil;
      end
    });
  end
};
