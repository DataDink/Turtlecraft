function turtlecraft:utilities()

   function self.indexes(t)
      local names = {};
      for name in pairs(t) names[name] = true; end
      return names;
   end

   function self.contains(t, value)
      for _, v in pairs(t)
         if (v == value) then return true; end
      end
      return false;
   end

end

turtlecraft.register.singleton('utilities', {turtlecraft.utilities});
