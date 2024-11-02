if (not turtle) then error("excavate_boundary requires a turtle") end

os.loadAPI('turtle.track.api')
os.loadAPI('turtle.boundary.api')

local resuming = arg and arg[1] == "resume"
if (not resuming) then
  turtle.track.clear()
  shell.run('recover excavate_boundary resume')
end

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print("Excavates a rectangular boundary down to bedrock.")
  print("Attempts to recover when reloaded.")
  print("Requires fuel in slot #1")
  print("")
  print(message)
end

function checkFuel()
  
end
