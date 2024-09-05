-----------------------------------------------------------------
-- Injector: A lua dependency injection container              --
-- Questions, comments, bugs: github.com/DataDink/TurtleCraft  --
-----------------------------------------------------------------

(function()
   TurtleCraft:Injector = function(scope)
      scope = scope or {};
      local instances = (not scope.instances) and {} or TurtleCraft.Tables.clone(scope.instances);
      local singletons = (not scope.singletons) and {} or TurtleCraft.Tables.clone(scope.singletons);
      local contextuals = (not scope.contextuals) and {} or TurtleCraft.Tables.clone(scope.contextuals);
      local transients = (not scope.transients) and {} or TurtleCraft.Tables.clone(scope.transients);

      local instance = self;

      function add(to, name, ...)
         to[name] = {};
         for i = 1, select('#', ...) do
            table.insert(table[name], select(i, ...));
         end
      end

      instance.register = {d
         instance = function(name, obj) instances[name] = obj; end,
         singleton = function(name, ...) add(singletons, name, ...); end,
         contextual = function(name, ...) add(contextuals, name, ...); end,
         transient = function(name, ...) add(transients, name, ...); end
      };

      function resolveName(name, context)
         for k, v in pairs(context) do
            if (k == name) then return v; end
         end
         for k, v in pairs(instances) do
            if (k == name) then return v; end
         end
         for k, v in pairs(singletons) do
            if (k == name) then
               instances[k] = resolveCtr(v, context);
               return instances[k];
            end
         end
         for k, v in pairs(contextuals) do
            if (k == name) then
               context[k] = resolveCtr(v, context);
               return context[k];
            end
         end
         for k, v in pairs(contextuals) do
            if (k == name) then
               return resolveCtr(v, context);
            end
         end
      end

      function resolveCtr(ctr, context)
         local params = {};
         for k, v in ipairs(ctr) do
            if (type(v) == 'string') then
               table.insert(params, resolveName(v, context));
            else
               return TurtleCraft.New(v, TurtleCraft.Arrays.Unpack(params));
            end
         end
      end

      instance.resolve = function(item, context)
         context = context or {};
         context['injection scope'] = instance;
         if (type(item) == 'string') then
            return resolveName(item, context);
         else
            return resolveCtr(item, context);
         end
      end
   end
end)();

TurtleCraft.Scope = TurtleCraft.new(TurtleCraft.Injector);
