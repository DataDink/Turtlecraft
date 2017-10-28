TurtleCraft.export('services/excavate', function()
  return {
    start = function()
      local input = TurtleCraft.import('ui/user-input').show('bla bla bla bla bla bla bla bla bla bla bla bla bla');
      TurtleCraft.import('ui/views/notification').show(input);
      TurtleCraft.import('services/io').readKey();
    end
  }
end).onready(function()
  TurtleCraft.import('services/plugins').register(
    'Excavate',
    function()
      TurtleCraft.import('services/excavate').start();
    end
  )
end);
