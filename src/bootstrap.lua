(function()
  if (os.getComputerLabel() == nil) then os.setComputerLabel('TurtleCraft'); end

  TurtleCraft.start();
  TurtleCraft.import('ui/plugin-menu').show('Exit TurtleCraft');
  term.clear();
  term.setCursorPos(1,1);
  print('TurtleCraft exited');
end)();
