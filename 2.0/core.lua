turtlecraft = {};

-- TurtleCraft
-- "core.lua":
--    Initializes the "turtlecraft" namespace and provides dependency injection services
-----------------------------------------------------------------------------------------------------
-- "Constructor":
--    Constructors are methods that receive and configure a unique "self" instance when
--    run.
--    Example:
--       function turtlecraft:MyClass()
--          self.value = 'test';
--       end
--
-- "Dependency":
--    A dependency is a "Constructor" wrapped in an array-table and preceded
--    by dependency names required for construction.
--    Example:
--       function turtlecraft:MyService(dep1, dep2) ... end -- constructor
--       local DC = {'depencency1', 'dependency2', turtlecraft.MyService} -- dependency
--
-- "Dependency Registration":
--    Dependencies must be registered by name with TurtleCraft in order to be accessible to other
--    services / dependencies. There are 4 different types of registrations:
--
--    Singleton:  turtlecraft.register.singleton(name, dependency)
--                A singleton dependency will only be constructed once and recycled
--                for each future requirement.
--
--    Scope:      turtlecraft.register.scope(name, dependency)
--                A scope dependency will be constructed once per resolution chain. For example:
--                If "serviceA" requires "dependency1" and "serviceB", while also "serviceB"
--                requires "dependency1", then both "serviceA" and "serviceB" will receive
--                the same copy of "dependency1".
--
--    Transient:  turtlecraft.register.transient(name, dependency)
--                A transient dependency will be newly constructed every time it is required.
--
--    You can also register a pre-constructed dependency by instance using the
--    turtlecraft.register.instance(name, object). This operates exactly like a singleton
--    but does not need to be constructed by turtlecraft.
--
-- "Resolving Dependencies":
--    If you need to manually resolve a dependency use the turtlecraft.resolve method.
--    Examples:
--       local svc = turtlecraft.resolve('MyService');
--       local svc = turtlecraft.resolve({'dependency1', 'dependency2', turtlecraft.MyService});
--       local svc = turtlecraft.resolve('MyService', {dependency1 = MyDependency});
-----------------------------------------------------------------------------------------------------

(function()
   local instances = {};
   local singletons = {};
   local scopes = {};
   local transients = {};

   local function indexes(obj)
      local result = {};
      for name in ipairs do
         result[name] = true;
      end
      return result;
   end

   unpack = unpack or function(items, fields, index)
      if (fields == nil) then
         index = 1;
         fields = indexes(items);
      end
      if (fields[index] == true) then
         return items[index], args(items, fields, index + 1);
      end
   end

   turtlecraft.register = {
      instance =  function(name, instance)   instances[name] = instance; end,
      singleton = function(name, singleton)  singletons[name] = singleton; end,
      scope =     function(name, scope)      scopes[name] = scope; end,
      transient = function(name, transient)  transients[name] = transient; end
   };

   local function resolveName(name, scope)
      if (indexes(scope)[name] == true) then return scope[name]; end
      if (indexes(instances)[name] == true) then return instances[name]; end
      if (indexes(singletons)[name] == true) then
         instances[name] = resolveConstructor(singletons[name], scope);
         return instances[name];
      end
      if (indexes[scopes][name] == true) then
         scope[name] = resolveConstructor(scopes[name], scope);
         return scope[name];
      end
      if (indexes[transients][name] == true) then
         return resolveConstructor(transients[name], scope);
      end
   end

   local function resolveConstructor(item, scope)
      var values = {};
      for _, req in pairs(item) do
         if (type(req) == 'string') then
            table.insert(values, resolveName(name, scope));
         else
            local this = {};
            this.constructor = req;
            this:constructor(args(values));
            return this;
         end
      end
   end

   function turtlecraft.resolve(item, scope)
      scope = scope or {};
      if (type(item) == 'table') then resolveConstructor(item, scope);
      else resolveName(item, scope); end
   end
end)();
