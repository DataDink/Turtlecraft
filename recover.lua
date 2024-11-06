print('Recover will configure this computer to run a command each time a computer boots.')
print('Example: recover.lua myprogram.lua arg1 arg2')

if (not arg or #arg == 0) then
  print()
  print('no program specified')
  return
end

local files = fs.complete(arg[1])
if (not files or #files == 0) then
  print()
  print(arg[1] .. ' not found')
  return
end

if (#files > 1) then
  print()
  print(arg[1] .. ' ambiguous: ' .. table.concat(files, ','))
  return
end

local file = files[1]
os.setComputerLabel('Job: ' .. string.gsub(file, '%.%w+', ''))

local startup = 'shell.run(' .. table.concat(
for i = 2,#arg do
  startup = startup .. "'" .. arg[i] .. "'"
  if (i < #arg) then startup = startup .. ', ' end
end
startup = startup .. ')\n'

local file = io.open('startup.lua', 'w+')
file:write(startup)
file:flush()
file:close()

os.reboot()
