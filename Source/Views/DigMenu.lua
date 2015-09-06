function class :DigMenu(view, items)
   self.name = 'Dig Stuff';
   self.help = 'Dig Stuff:\r\nThis will show you all of the dig-related functions available for turtles. All of these functions will require a mining turtle.';
   function self:start() view:show(); end

   items = items or {};
   if (#items == 0) then items = {items}; end
   for _, item in ipairs(items or {}) do
      view:add(item.name, item.start, item.help);
   end
end
ModCraft.register.dependency('menu-items', {'menu', 'dig-items'})
