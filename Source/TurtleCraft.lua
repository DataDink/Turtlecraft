(function()
   function class :TurtleCraft(menu, injector, items)
      local function add(item)
         if (type(item.name) ~= 'string') then error('menu item missing name'); end
         if (type(item.action) ~= 'function') then error('menu item missing action'); end
         menu.add(item.name, item.action, tostring(item.help or 'No help available'));
      end
      function self:start()
         if (not items) then items = {};
         elseif (#items == 0) then items = {items}; end
         for _, item in ipairs(items) do add(item); end
         menu:show();
      end
   end
   ModCraft.register.module('turtlecraft', {'menu', 'dependencies', 'menu-items', class.TurtleCraft});
end)();
