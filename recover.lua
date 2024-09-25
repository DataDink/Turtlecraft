print('Recover will configure this computer to run a command each time a computer boots.')
print('Example: recover.lua myprogram.lua arg1 arg2')

if (#arg > 0) then
  os.setComputerLabel(arg[1])
  
  local startup = 'shell.run('
  for i,v in ipairs(arg) do
    startup = startup .. "'" .. v .. "'"
    if (i < #arg) then startup = startup .. ', ' end
  end
  startup = startup .. ')\n'
  
  local file = io.open('startup.lua', 'w+')
  file:write(startup)
  file:flush()
  file:close()
  
  os.reboot()
end
