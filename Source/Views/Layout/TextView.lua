(function()
   local display = {};
   display.width, display.height = term.getSize();
   local hr = string.rep('=', display.width);

   function class .Views.Layout:TextView()
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
            local isBreak = space:find('\n')
                        or space:find('\r')
                        or #line + #space > width;
            if (isBreak) then
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
   ModCraft.register.dependency.transient('views.layout.text', class.Views.Layout.TextView);
end)();
