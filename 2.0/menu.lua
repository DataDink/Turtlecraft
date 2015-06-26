function turtlecraft:menu()
   local items = {};
   local index = 1;
   local count = 0;

   local width, height = term.getSize();
   local break = '...';
   local header = 4;
   local footer = 2;
   local padding = 1;

   function self.add(name, item)
      table.insert(items, {name = name, item = item});
      count = count + 1;
   end

   function self.start()

   end

   function print(x, y, text)
      term.setCursorPos(x, y);
      term.write(text);
   end

   function printLine(y, text)
      var totalPadding = padding * 2;
      term.setCursorPos(padding, y);
      term.clearLine();
      if (text:len() > (width - totalPadding))
         text = text:sub(1, width - totalPadding - break:len()) .. break;
      end
      term.write(' ' .. text);
   end

   function printCentered(y, text)
      var offset = math.max(0, (width - (padding * 2) - text:len()) / 2);
      var pad = string.rep(' ', math.floor(offset));
      printLine(pad .. text);
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
