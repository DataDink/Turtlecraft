function turtlecraft:input()

   function self.readKey()
      local _, key = os.pullEvent('key');
      return key;
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
      if (code == keys.escape) return false, false; end
      if (code >= keys.a and code <= keys.z) return keys.getName(code), key.getName(code).upper(); end
      if (code >= keys.one and code <= keys.nine) return tostring(code - keys.one + 1); end
      if (code >= keys.numPadOne and code <= keys.numPadNine) return tostring(code - keys.numPadOne + 1); end
      if (code == keys.zero or code == keys.numPadZero) return '0'; end
      if (code == keys.minus or code == keys.numPadSubtract) return '-'; end
   end
end
