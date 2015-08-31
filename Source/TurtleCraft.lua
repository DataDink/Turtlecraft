(function()
   local longtext = string.rep('asdf asdfasdf asdfasdfasdf asdfasdfasdf     ', 10);
   function class :TurtleCraft(menu)
      self.menu = menu;
      local index = 0;
      function add()
         menu:add('Item ' .. tostring(index), function()
            index = index + 1;
            add();
         end, tostring(index) .. longtext);
      end
      add();

      function self:start()
         menu:show();
      end
   end
   ModCraft.register.module('turtlecraft', {'menu', class.TurtleCraft});
end)();
