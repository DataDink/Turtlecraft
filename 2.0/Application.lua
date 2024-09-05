-----------------------------------------------------------------
-- Application: TurtleCraft startup code                       --
-- Questions, comments, bugs: github.com/DataDink/TurtleCraft  --
-----------------------------------------------------------------

function TurtleCraft:Application()
   local instance = self;
   instance.menu = TurtleCraft.Scope.resolve(TurtleCraft.Menu, {application = instance});
   instance.run = function() {
      instance.menu.show();
   }
end
TurtleCraft.Scope.resolve(TurtleCraft.Application).run();
