------------------------------------------------------------
--  ModCraft.lua
--  By DataDink
--
--  Source & Docs: https://www.github.com/DataDink/ModCraft
--  License: MIT
------------------------------------------------------------

(function()
   function createNS() -- This generates an isolated set of registration/construction namespace roots
      local constructor, buildInstance, constructAll;
      local descriptors = {};

      local function resolvename(base, key) return (#base == 0) and key or base .. '.' .. key; end

      -- Namespaces are virtual tables that can be traversed and assigned to dynamically
      local function namespace(base, resolve)
         base = tostring(base);
         return setmetatable({}, {
            -- maintain metatable integrity
            __metatable = false,

            -- return requested class or next virtual namespace
            __index = function(t, k)
               local name = resolvename(base, k);
               local descriptor = descriptors[name];
               if (resolve and descriptor) then return t(k); end
               return descriptors[name] or namespace(name, resolve);
            end,

            -- register a new class descriptor
            __newindex = function(ns, k, v)
               if (resolve) then error('Invalid Operation'); end
               if (type(v) == 'function') then v = {constructor = v}; end
               if (type(v) ~= 'table') then error('Invalid Class Descriptor'); end
               local name = resolvename(base, k);
               descriptors[name] = setmetatable({}, {
                  __metatable = false,
                  __newindex = function() error('class descriptors should not be edited'); end,
                  __index = function(c, k)
                     if (k == '__name') then return name; end
                     if (k == '__namespace') then return ns; end
                     return v[k];
                  end,
                  __pairs = function() return pairs(v); end
               });
            end,

            -- generate a constructor function
            __call = function(t, k)
               local name = resolvename(base, k);
               local descriptor = descriptors[name];
               if (not descriptor) then return false; end
               return constructor(t, name, descriptor);
            end,

            -- compares namespaces
            __eq = function(a, b)
               if (type(a) == 'table') then a = getmetatable(a); end
               if (type(b) == 'table') then b = getmetatable(b); end
               if (type(a) == 'table') then a = a.path; end
               if (type(b) == 'table') then b = b.path; end
               return a == b;
            end,

            -- resolve namespace path
            __tostring = function()
               return base;
            end
         });
      end

      -- Inherits static members starting at the most base descriptor
      function buildInstance(descriptor)
         if (type(descriptor) ~= 'table') then return {}; end
         local instance = buildInstance(descriptor.inherits);
         for k, v in pairs(descriptor) do
            if (k ~= 'inherits'
            and k ~= 'constructor') then
               instance[k] = descriptor[k];
            end
         end
         return instance;
      end

      -- Runs all constructors starting at the most base descriptor
      function constructAll(descriptor, instance, ...)
         if (type(descriptor) ~= 'table') then return; end
         constructAll(descriptor.inherits, instance, ...);
         if (not descriptor.constructor) then return; end
         descriptor.constructor(instance, select(2, ...));
      end

      -- Builds a class constructor
      function constructor(namespace, name, descriptor)
         return function(...)
            local instance = buildInstance(descriptor);
            instance.__name = name;
            instance.__type = descriptor;
            instance.__namespace = namespace;
            constructAll(descriptor, instance, ...);
            return instance;
         end
      end

      -- A namespace root that can have classes added to it
      local registration = namespace('', false);

      -- A namespace root that will return an executable constructor instead of a class
      local construction = namespace('', true);

      -- class & new
      return registration, construction;
   end

   class, new = createNS(); -- Adds the global class/new keys

   function class:NameSpace() return createNS(); end -- Exposes custom namespace scoping
end)();


--

--------------------------------------------------------------------------
--  DependencyResolver
--
--  Documentation: https://www.github.com/DataDink/ModCraft
--------------------------------------------------------------------------

-- Create a new container: local container = new.ModCraft:DependencyResolver();
-- Create a child container: local child = container.branch();
-- Register a service: container.register.singleton('name', {'dependency', class.MyClass});
-- Resolve a service: local service = container.resolve('name');
-- Override a dependency: local service = container.resolve('name', {dependency: {}});
-- Also available: register.instance(names, object), register.contextual(names, constructor), register.transient(names, constructor);
-- Also available: (name, class), (name, {dependencies}, class), ({names}, {dependencies}, class), (name, {dependencies, class}), etc
(function()
   local createRegistration, readonly, strings, constructor, createContext, resolveName, resolveConstructor; -- helper declarations

   class .ModCraft.DependencyResolver = {
      constructor = function(self)
         local resolver = {};
         local registry = {};

         resolver.register = readonly({
            instance = function(names, object)
               local reg = createRegistration(false, names);
               reg.singleton = true;
               reg.instance = object;
               table.insert(registry, reg);
            end,
            singleton = function(names, dependencies, class)
               local reg = createRegistration(true, names, dependencies, class);
               reg.singleton = true;
               table.insert(registry, reg);
            end,
            contextual = function(names, dependencies, class)
               local reg = createRegistration(true, names, dependencies, class);
               reg.contextual = true;
               table.insert(registry, reg);
            end,
            transient = function(names, dependencies, class)
               local reg = createRegistration(true, names, dependencies, class);
               table.insert(registry, reg);
            end
         });

         resolver.branch = function()
            local child = new .ModCraft:DependencyResolver();
            for _, reg in ipairs(registry) do
               if (reg.instance ~= nil) then child.register.instance(reg.names, reg.instance);
               elseif (reg.singleton) then child.register.singleton(reg.names, reg.dependencies, reg.class);
               elseif (reg.contextual) then child.register.contextual(reg.names, reg.dependencies, reg.class);
               else child.register.transient(reg.names, reg.dependencies, reg.class); end
            end
            return child;
         end

         resolver.resolve = function(...)
            local context = createContext(registry);
            local name, overrides = select(1, ...);
            if (type(name) == 'string') then return resolveName(name, context, overrides or {}); end

            local class, overrides = select(1, ...);
            local ctor = constructor(class);
            if (ctor) then return resolveConstructor({}, ctor, context, overrides or {}); end

            local dependencies, class, overrides = select(1, ...);
            local ctor = constructor(class);
            if (ctor) then return resolveConstructor(dependencies, ctor, context, overrides or {}); end

            local group, overrides = select(1, ...);
            local class = table.remove(group);
            local ctor = constructor(class);
            if (ctor) then return resolveConstructor(group, ctor, context, overrides or {}); end

            error("Can't resolve requested signature");
         end

         readonly(resolver, self);
      end
   };

   -- Fronts a table with a readonly proxy
   function readonly(backing, proxy)
      return setmetatable(proxy or {}, {
         __metatable = false,
         __newindex = function() error('This object should remain read-only') end,
         __index = function(t, k) return backing[k]; end,
         __pairs = function() return pairs(backing); end
      });
   end

   -- Maintains information about a dependency
   function createRegistration(require, names, dependencies, class)
      local reg = {names = {}, dependencies = {}, constructor = false, singleton = false, contextual = false};

      -- Names
      reg.names = strings(names);
      if (#reg.names == 0) then error('No name(s) specified'); end

      -- Constructor
      reg.constructor = constructor(dependencies);
      if (reg.constructor) then
         reg.class = dependencies;
         dependencies = {};
      end
      if (not reg.constructor) then
         reg.class = class;
         reg.constructor = constructor(class);
      end
      if (not reg.constructor and type(dependencies) == 'table') then
         reg.class = table.remove(dependencies);
         reg.constructor = constructor(reg.class);
      end
      if (not reg.constructor and require) then error('Class not specified'); end

      -- Dependencies
      reg.dependencies = strings(dependencies);

      return reg;
   end

   -- Ensures a collection of strings or empty collection
   function strings(items)
      items = (type(items) == 'table') and items or {items};
      local filtered = {};
      for _, v in ipairs(items) do
         if (type(v) == 'string') then table.insert(filtered, v); end
      end
      return filtered;
   end

   -- Maintains referencial integrity between resolution contexts
   function createContext(registry)
      local context = {};
      for _, reg in ipairs(registry) do
         if (reg.singleton) then table.insert(context, reg);
         else table.insert(context, {
               names = reg.names,
               dependencies = reg.dependencies,
               constructor = reg.constructor,
               singleton = reg.singleton,
               contextual = reg.contextual
            });
         end
      end
      return context;
   end

   -- Identifies and extracts a class construction method or false
   function constructor(class)
      if (type(class) ~= 'table') then return false; end
      if (type(class.__name) ~= 'string') then return false; end
      local name = class.__name;
      if (type(class.__namespace) ~= 'table') then return false; end
      local namespace = tostring(class.__namespace);
      if (string.sub(name, 1, #namespace) ~= namespace) then return false; end
      name = string.sub(name, #namespace);
      local ctor = class.__namespace(name);
      if (not ctor) then return false; end
      return function(...) return ctor(nil, ...); end
   end

   function resolveName(name, context, overrides)
      if (overrides[name] ~= nil) then return overrides[name]; end
      local matches = {};
      for _, r in pairs(context) do
         for _, n in pairs(r.names) do
            if (n == name) then
               table.insert(matches, r);
               break;
            end
         end
      end
      local resolves = {};
      for _, m in pairs(matches) do
         if (m.instance ~= nil) then table.insert(resolves, m.instance);
         else
            local instance = resolveConstructor(m.dependencies, m.constructor, context, overrides);
            table.insert(resolves, instance);
            if (m.singleton or m.contextual) then m.instance = instance; end
         end
      end
      return (#resolves > 1) and resolves or resolves[1];
   end

   function resolveConstructor(dependencies, ctor, context, overrides)
      local resolves = {};
      for _, n in pairs(dependencies) do
         table.insert(resolves, resolveName(n, context, overrides));
      end
      return ctor(args(resolves));
   end

   function args(dependencies)
      if (#dependencies > 0) then
         return table.remove(dependencies, 1), args(dependencies);
      end
   end
end)();


--

--------------------------------------------------------------------------
--  Application
--  Hosts a dependency scope and manages application resources
--
--  Documentation: https://www.github.com/DataDink/ModCraft
--------------------------------------------------------------------------

(function()
   local readonly, cycle, registry, join;
   local root = new .ModCraft:DependencyResolver();

   -- Application
   function class .ModCraft:Application()
      local scope = root.branch();
      scope.register.instance('dependencies', scope);
      scope.register.instance('application', self);

      local service = {};
      local backing = {};
      service.register = registry(scope, backing);
      service.resolve = scope.resolve;
      service.start = function()
         backing.module = function() error('Module added after start. Please use .dependency to register late dependencies.'); end
         backing.service = function() error('Service added after start. Please use .dependency to register late dependencies.'); end
         service.start = function() error('Application already started.'); end

         local modules = scope.resolve('modules');
         if (modules ~= nil) then
            if (#modules == 0) then modules = {modules} end;
            cycle(modules, 'init');
            cycle(modules, 'start');
         end
      end
      readonly(service, self);
   end

   function readonly(source, proxy, ex)
      return setmetatable(proxy or {}, {
         __metatable = false,
         __newindex = function() error('This object should remain readonly') end,
         __index = function(t, k) return source[k]; end,
         __pairs = function() return pairs(source); end,
         __call = ex
      });
   end

   function cycle(items, action)
      for _, item in pairs(items) do
         if (type(item[action]) == 'function') then
            item[action]();
         end
      end
   end

   function join(a, b)
      a = type(a) == 'string' and {a} or a;
      b = type(b) == 'string' and {b} or b;
      local concat = {};
      for _, v in ipairs(a) do table.insert(concat, v); end
      for _, v in ipairs(b) do table.insert(concat, v); end
      return concat;
   end

   -- A common registration interface for ModCraft
   function registry(scope, backing)
      backing = backing or {};
      backing.service = function(names, dependencies, constructor)
         scope.register.singleton(join(names, 'services'), dependencies, constructor);
      end
      backing.module = function(names, dependencies, constructor)
         scope.register.singleton(join(names, 'modules'), dependencies, constructor);
      end
      backing.dependency = readonly({
         instance = scope.register.instance,
         singleton = scope.register.singleton,
         contextual = scope.register.contextual,
         transient = scope.register.transient
      }, {}, scope.register.contextual);
      return readonly(backing);
   end

   -- Global registry
   ModCraft = readonly({
      register = registry(root),
      resolve = root.resolve,
      start = function()
         local application = new .ModCraft:Application();
         application.start();
         return application;
      end
   });
end)();


--

(function()
   function class:Menu(view, scroll)
      local options = {};
      local index = 1;

      local function render()
         view:refresh(false, 'up/down/left/enter h->help');
         local scrollMax = math.max(0, #options - view.content);
         local scroll = math.floor(index - (view.content / 2));
         scroll = math.max(0, math.min(scrollMax, scroll));
         for l = 1, view.content do
            local i = l + scroll;
            local option = options[i];
            if (option) then
               local text = option.text;
               text = (i == index and '>' or '|') .. text;
               view:write(text, view.headerHeight + l)
            else
               view:write('', view.headerHeight + l);
            end
         end
      end

      function self:add(text, action, help)
         table.insert(options, {text = text, action = action, help = (help or 'There is no help for this option.')});
      end

      function self:show(canExit)
         while true do
            render();
            local _, key = os.pullEvent('key');
            if (canExit and key == keys.left) then return; end
            if (key == keys.up) then index = math.max(1, index - 1); end
            if (key == keys.down) then index = math.min(#options, index + 1); end
            if (key == keys.enter or key == keys.numPadEnter) then
               term.clear();
               local option = options[index];
               option.action();
            end
            if (key == keys.h) then
               term.clear();
               local option = options[index];
               if (option.help) then scroll:show(option.help); end
            end
         end
      end
   end
   ModCraft.register.dependency.transient('menu', {'text-view', 'scroll-view', class.Menu});
end)();


--

(function()
   function class:ScrollView(view)
      function self:show(text, title)
         local lines = view:wrap(text or '');
         local scroll = 0;
         local scrollMax = math.max(0, #lines - view.content);
         while(true) do
            view:refresh(title, 'up/down enter->exit');
            for i = 1, view.content do
               local line = lines[scroll + i];
               if (not line) then break; end
               view:write(line, i + view.headerHeight);
            end
            local _, key = os.pullEvent('key');
            if (key == keys.enter or key == keys.numPadEnter) then return; end
            if (key == keys.up) then scroll = math.max(0, scroll - 1); end
            if (key == keys.down) then scroll = math.min(scrollMax, scroll + 1); end
         end
         term.clear();
      end
   end
   ModCraft.register.service('scroll-view', {'text-view', class.ScrollView});
end)();


--

(function()
   local display = {};
   display.width, display.height = term.getSize();
   local hr = string.rep('=', display.width);

   function class:TextView()
      self.width = display.width;
      self.height = display.height;
      self.top = 4;
      self.bottom = display.height - 2;
      self.content = display.height - 5;
      self.headerHeight = 3;
      self.footerHeight = 2;

      function self:write(str, y, x)
         x = x or 1;
         if (y) then term.setCursorPos(x, y); end
         term.clearLine();
         term.write(str);
      end
      function self:hr(y) self:write(hr, y); end
      function self:center(text, y)
         text = text or '';
         local left = math.floor((self.width / 2) - (#text / 2));
         self:write(text, y, math.max(0, text));
      end
      function self:wrap(text, width)
         width = width or self.width;
         local lines = {}; local line = '';
         local blocks = (text or ''):gmatch('%W*%w+');
         for block in blocks do
            local word = block:match('%w+') or '';
            local space = block:match('%W+') or '';
            if (#line + #space > width) then
               table.insert(lines, line);
               line = '';
            else line = line .. space; end
            if (#line + #word > width) then
               table.insert(lines, line);
               line = '';
            end
            line = line .. word;
         end
         table.insert(lines, line);
         return lines;
      end

      function self:renderHeader(text)
         text = text or 'TurtleCraft';
         self:hr(1);
         self:write(text, 2);
         self:hr(3);
      end
      function self:renderFooter(text)
         text = text or 'github.com/DataDink/TurtleCraft';
         self:hr(self.height - 1);
         self:write(text, self.height);
      end
      function self:refresh(header, footer)
         term.clear();
         self:renderHeader(header);
         self:renderFooter(footer);
      end
   end
   ModCraft.register.dependency.transient('text-view', class.TextView);
end)();


--

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


--

ModCraft.start();
