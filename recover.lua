print('Recover will configure this computer to run a command each time a computer boots.')
print('Example: recover.lua myprogram.lua arg1 arg2')

if (arg and arg[1] == "help") then
  return
end

if (not arg or #arg == 0) then
  print()
  print('no program specified')
  return
end

os.setComputerLabel('Job: ' .. string.gsub(arg[1], '%.%w+', ''))

local file = io.open('startup.lua', 'w+')
file:write('shell.run("' .. table.concat(arg, '", "') .. '")\n')
file:flush()
file:close()

os.reboot()
