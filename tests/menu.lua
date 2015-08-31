dofile('test.lua');
dofile('../../ModCraft/lua/Builds/modcraft.lua');
dofile('../Source/menu.lua');

test('Tests', function(ass)
   term = {
      getSize = function() return 0, 0; end
   }
   local menu = ModCraft.resolve('menu');
   ass.truthy(menu, 'Registered');
   ass.truthy(menu.title and menu.instructions, 'Default Values');
   ass.succeeds(function()

   end, 'Add');
end);
