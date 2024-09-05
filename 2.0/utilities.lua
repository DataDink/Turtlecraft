-----------------------------------------------------------------
-- Utilities: Root, static functionality                       --
-- Questions, comments, bugs: github.com/DataDink/TurtleCraft  --
-----------------------------------------------------------------

TurtleCraft.Tables = {
   clone = function(tbl)
      local clone = {};
      for k, v in pairs(tbl) do
         clone[k] = v;
      end
      return clone;
   end,
   length = function(tbl)
      local count = 0;
      for k, v in ipairs(tbl) do count = count + 1; end
      return count;
   end
}

TurtleCraft.new = function(constructor, ...)
   local instance = {};
   instance.constructor = constructor;
   return instance:constructor(select('1', ...));
end
