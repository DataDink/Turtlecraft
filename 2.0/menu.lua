-----------------------------------------------------------------
-- Menu: Manages and displays options and user selections      --
-- Questions, comments, bugs: github.com/DataDink/TurtleCraft  --
-----------------------------------------------------------------

function TurtleCraft:Menu()
   local instance = self;

   local items = {};
   local index = 1;
   local count = 0;

   local view = {};
   view.width, view.height = term.getSize();
   view.break = '...';
   view.top = 4;
   view.bottom = view.height - 2;
   view.left = 3;
   view.right = view.width - 3;
   view.hr = function(y)
      term.setCursorPos(1, y);
      term.write(string.rep('-', view.width));
   end
   view.print = function(x, y, text)
      term.setCursorPos(x, y);
      term.write(text);
   end
   view.printLine = function(y, text)
      term.setCursorPos(view.left, y);
      term.clearLine();
      local max = view.right - view.left;
      if (text:len() > max) then text = text:sub(1, max - view.break:len()) .. view.break; end
      term.write(text);
   end
   view.printCenter = function(y, text)
      local max = view.right - view.left;
      local offset = math.max(1, (max - text:len()) / 2);
      view.print(offset, y, text);
   end
   view.render = function()
      for i = 1, view.height do
         term.setCursorPos(1, i);
         term.clearLine();
         term.write('|');
         term.setCursorPos(view.width, i);
         term.write('|');
      end
      view.hr(1);
      view.hr(3);
      view.hr(view.height);
      view.printCenter(2, 'TurtleCraft 2.0');

      local max = view.bottom - view.top;
      local start = math.max(1, count - (max / 2));
      local end = view.bottom - start;
      for i = 0, end - start do
         local y = view.top + i;
         local item = start + i;
         if (item > TurtleCraft.Tables.length(items)) then break; end
         term.setCursorPos(view.left, y);
         if (item == index) then term.write('>');
         else term.write(' '); end
         term.write(items[item].label);
      end
   end

   local input = {};
   input.read = function()
      local code = os.pullEvent('key');
      return code;
   end
   input.wait = function(filter)
      while (true) do
         local code = 
      end
   end

   instance.action = function(label, action)
      table.insert(items, {label = label, action = action});
   end

   instance.menu = function(label)
      local submenu = TurtleCraft.new(TurtleCraft.Menu);
      table.insert(items, {label = label, action = function()
         submenu.show(true);
      end});
      return submenu;
   end

   instance.show = function(canBack)
      canBack = canBack or false;

   end






   local width, height = term.getSize();
   local break = '...';
   local top = 4;
   local bottom = height - 2;
   local left = 2;
   local right = width - 2;

   function self.add(name, item)
      table.insert(items, {name = name, item = item});
      count = count + 1;
   end




   local header = 4;
   local footer = 2;
   local padding = 1;

   function self.start()
      while (true) do
         render();
         local code = input.read();
         if (code == keys.up) then index = math.max(1, index - 1); end
         if (code == keys.down) then index = math.min(item:len(), index + 1); end
         if (code == keys.enter) then
            -- is typeof menu
            -- start menu
            -- else run function
         end
      end
   end

   function render()
      term.clear();
      renderHeader();
      renderMenu();
      renderFooter();
   end

   function renderHeader()
      print(1, 1, string.rep('-', width));
      printCentered(2, 'TurtleCraft 2.0');
      print(1, 3, string.rep('-', width));
   end

   function renderFooter()
      print(1, height, string.rep('-', width));
   end

   function renderMenu()
      local available = height - header - footer;
      local start = math.max(1, index - math.floor(available / 2 - 1));
      local end = start + available;
      for i = 0, available do
         local line = header + i;
         local item = start + i;
         if (item > count) { break; }
         local text = items[item].name;
         if (item == index) text = '>' .. text; end
         printLine(line, text);
      end
   end
end
