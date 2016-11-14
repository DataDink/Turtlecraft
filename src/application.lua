TurtleCraft = {};
TurtleCraft.Services = {};
TurtleCraft.Modules = {};
TurtleCraft.__index = TurtleCraft;

function TurtleCraft.new(menu, resume, position)
  local self = setmetatable({}, TurtleCraft);

  function self.start()
    term.clear();
    term.setCursorPos(1, 1);
    term.write('=====================');
    term.write('= TurtleCraft 2.0.0 =');
    term.write('= by DataDink       =');
    term.write('=====================');
    term.write('Starting TurtleCraft');
    term.write('Hello!');
    os.sleep(5);
    position.init();
    resume.init();
    menu.init();
    term.clear();
    term.write('Exiting TurtleCraft');
    term.write('Goodbye!');
  end

  return self;
end
