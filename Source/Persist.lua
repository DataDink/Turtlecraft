(function()
   local root = 'turtlecraft/cache/';

   function class:Persist()
      local path = root .. '.default';
      local data = '';

      function self:key(key)
         path = root .. key .. '.cache';
         return read();
      end

      function self:get() return data; end

      -- It is crucial that this is executed in as few steps as possible
      function self:set(value)
         local file = fs.open(path, 'w');
         file.write(value);
         file.close();
         data = value;
      end

      local function read()
         local file = fs.open(path, 'r');
         data = file.readAll();
         file.close();
         return data;
      end
      read();
   end
   ModCraft.register.dependency.transient('persist', class.Persist);

   local pre = '';
   for part in cachepath:gmatch('[^/]') do
      pre = pre .. '/' .. part;
      if (fs.exists(pre) and not fs.isDir(pre)) then fs.delete(pre); end
      if (not fs.exists(pre)) then fs.makeDir(pre); end
   end
end)();
