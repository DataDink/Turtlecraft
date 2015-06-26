function turtlecraft:ensure(config)
   local path = config.path + 'ensure.dat';

   local function execute()
      if (fs.exists(path)) then
         var recovery = fs.open(path, 'r');
         loadstring(recovery.readall());
         fs.delete(path);
         recovery.close();
      end
   end
   execute();

   function self.execute(command)
      var persist = fs.open(path, 'w');
      persist.write(command);
      persist.close();
      execute();
   end

end

turtlecraft.register.singleton('ensure', {'configuration', turtlecraft.ensure});
