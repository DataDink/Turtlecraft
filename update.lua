local source = 'https://api.github.com/repos/DataDink/TurtleCraft'
print('************************')
print('Downloading from: ' .. source)
print()

local directory = textutils.unserializeJSON(http.get(source .. '/contents').readAll())
if (directory) then
  for i,v in ipairs(directory) do
    local extension = v.name:sub(-4);
    local filter = extension == '.lua'
                or extension == '.api'
    if (filter) then
      print('* ' .. v.name)
      local content = http.get(v.download_url).readAll()
      local file = io.open(v.name, 'w+')
      file:write(content)
      file:flush()
      file:close()
    end
  end
end

print('')
print('Download Complete')
print('************************')
print('')
