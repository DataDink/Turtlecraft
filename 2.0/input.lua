function turtlecraft:input(utils)

   function self.read() -- Read a single keystroke
      local _, code = os.pullEvent('key');
      if (utils.contains(printable, code) == false) then return code, false; end
      local _, char = os.pullEvent('char');
      return code, char;
   end

   local function input(min, max, width, strokeFilter, textFilter)
      min = min or 0;
      max = max or 1000; -- Srsly if you even allow 100 it will be a bad user experience.
      width = width or 1000;
      textFilter = textFilter or '.*';

      local w, h = term.getSize();
      local x, y = term.getCursorPos();

      local left = x;
      local right = math.min(w, left + width);
      width = right - left;
      local pos = 0;
      local scroll = 0;

      local buffer = '';
      while (true) do
         var code, char = self.read();
         if (code == keys.enter or code == keys.numPadEnter) then
            local lengthCheck = buffer:len() >= min and buffer:len() <= max;
            local filterCheck = textFilter(buffer);
            if (lengthCheck and filterCheck) then
               break;
            end
         end
         elseif (code == keys.left) then pos = pos - 1; end
         elseif (code == keys.right) then pos = pos + 1; end
         elseif (code == keys.up) then pos = 0; end
         elseif (code == keys.down) then pos = buffer:len(); end
         elseif (code == keys.backspace) then
            if (pos > 1) then
               buffer = buffer:sub(1, pos - 1) .. buffer:sub(pos + 1);
               pos = pos - 1;
            end
         end elseif (code == keys.delete) then
            buffer = buffer:sub(1, pos) .. buffer:sub(pos + 1);
         end elseif (strokeFilter(buffer, char, pos)) then
            buffer = buffer:sub(1, pos) .. char .. buffer:sub(pos + 1);
            pos = pos + 1;
         end

         local offset = pos - scroll;
         if (offset < 0) then scroll = scroll + offset; end
         if (offset > width) then scroll = scroll - (offset - width); end
         local display = buffer:sub(offset, width);
         local padding = string.rep(' ', math.max(0, width - display:len()));
         term.setCursorPos(left, y);
         term.write(display .. padding);
         term.setCursorPos(left + (pos - scroll), y);
         term.setCursorBlink(true);
      end

      term.setCursorBlink(false);
      return buffer;
   end

   function self.text(min, max, width, filter) -- Read a line of text
      local function checkStroke() return true; end
      local function checkText(t) return t:find(filter or '.*') ~= nil; end
      local function cleanText(t) return t; end
      return input(min, max, width, checkStroke, checkText, cleanText);
   end

   function self.number(min, max, width)
      local function checkText(t) return t:find('^%-?%d+%.?%d*$'); end -- If this language ever supports full regex change to ^%-?%d+(%.%d*)?$ end
      local function checkStroke(t, c, p)
         if (c == '-' and p == 0) then return true; end
         if (c == '.' and p > 0 and t:find('.') == nil)) then return true; end
         if (utils.contains({'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}, c)) then return true; end
         return false;
      end
   end

   local printable = {
      keys.a, keys.b, keys.c, keys.d, keys.e, keys.f, keys.g, keys.h, keys.i, keys.j, keys.k,
      keys.l, keys.m, keys.n, keys.o, keys.p, keys.q, keys.r, keys.s, keys.t, keys.u, keys.v,
      keys.w, keys.x, keys.y, keys.z,
      keys.one, keys.two, keys.three, keys.four, keys.five, keys.six, keys.seven, keys.eight,
      keys.nine, keys.zero,
      keys.minus, keys.equals, keys.tab, keys.leftBracket, keys.rightBracket,
      keys.semiColon, keys.apostrophe, keys.grave, keys.backslash, keys.comma, keys.period,
      keys.slash, keys.multiply, keys.space, keys.colon, keys.underscore
      keys.numPad1, keys.numPad2, keys.numPad3, keys.numPad4, keys.numPad5, keys.numPad6,
      keys.numPad7, keys.numPad8, keys.numPad9, keys.numPad0,
      keys.numPadSubtract, keys.numPadAdd, keys.numPadDecimal, keys.numPadEquals,
      keys.numPadComma, keys.numPadDivide,
   }
end

turtlecraft.register.singleton('input', {'utilities', turtlecraft.input});
