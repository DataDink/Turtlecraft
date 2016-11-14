TurtleCraft.Config = {
  appTitle = "TurtleCraft 2.0"
};

TurtleCraft.Config.displayWidth, TurtleCraft.Config.displayHeight = term.getSize();
TurtleCraft.Config.maxMenuDisplay = TurtleCraft.Config.displayHeight - 5;
TurtleCraft.Config.appHeader = string["repeat"]("=", TurtleCraft.Config.displayWidth) .. "\n"
                            .. "= " .. TurtleCraft.Config.appTitle .. "\n"
                            .. string["repeat"]("=", TurtleCraft.Config.displayWidth);
TurtleCraft.Config.appHeaderHeight = 3;
