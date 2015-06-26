function turtlecraft:input()

   function self.read()
      local code, char = false, false;
      parallel.waitForAll(
        function() _, code =
      );
   end

   function self.readChar()
      local _,
   end

   function self.readText(filter)
      return read();
   end

   function self.readNumber()
      var result = '';
      var key = false;
      while (key != keys.enter and key != keys.numPadEnter) do
         self.readKey
      end
   end

   function self.character(code)
      for i, v in pairs(codes) do
         if (v == code)
   end


   local codes = {
      keys.a, keys.b, keys.c, keys.d, keys.e, keys.f, keys.g, keys.h, keys.i, keys.j, keys.k,
      keys.l, keys.m, keys.n, keys.o, keys.p, keys.q, keys.r, keys.s, keys.t, keys.u, keys.v,
      keys.w, keys.x, keys.y, keys.z,
      keys.one, keys.two, keys.three, keys.four, keys.five, keys.six, keys.seven, keys.eight,
      keys.nine, keys.zero,
      keys.numPad1, keys.numPad2, keys.numPad3, keys.numPad4, keys.numPad5, keys.numPad6,
      keys.numPad7, keys.numPad8, keys.numPad9, keys.numPad0,
      keys.numPadSubtract, keys.numPadAdd, keys.numPadDecimal, keys.numPadEquals,
      keys.numPadEnter, keys.numPadComma, keys.numPadDivide,
      keys.minus, keys.equals, keys.tab, keys.leftBracket, keys.rightBracket, keys.enter,
      keys.semiColon, keys.apostrophe, keys.grave, keys.backslash, keys.comma, keys.period,
      keys.slash, keys.multiply, keys.space, keys.colon, keys.underscore
   };
   local lowercase = {
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
      's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
      '-', '+', '.', '=', '\r', ',', '/', '-', '=', ' ', '[', ']', '\r', ';', "'", '`', '\\',
      ',', '.', '/', '*', ' ', ':', '_'
   };
   local uppercase = {
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R'
      'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
      '!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
      '_', '+', ' ', '{', '}', '\r', ':', '"', '~', '|', '<', '>', '?', '*', ' ', ':', '_'
   };
end
