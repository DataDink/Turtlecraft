TurtleCraft.export('services/update', function()
  return {
    start = function()
      local config = TurtleCraft.import('services/config');
      local path = shell.getRunningProgram();
      term.clear();
      term.setCursorPos(1,1);
      print('Downloading Latest Version...');
      os.sleep(1);
      fs.delete(path);
      shell.run('pastebin', 'get', config.pastebin, path);
      print('Rebooting...');
      os.sleep(5);
      os.reboot();
    end;
  };
end).onready(function()
  TurtleCraft.import('services/plugins').register(
    'Update TurtleCraft',
    function()
      TurtleCraft.import('services/update').start();
    end,
    math.huge);
end);
