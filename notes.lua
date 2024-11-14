local source = arg and arg[1]

function display(message)
  term.clear()
  term.setCursorPos(1,1)
  print('Note plays music using a json file.')
  print("Each side can host a speaker as a channel.")
  print("note <string:url/file>")
  print("")
  print(message)
end
display("")

if (not source or not fs.exists(source) and not http.checkURL(source)) then return display("Invalid file or url.") end

local file = fs.exists(source) and fs.open(source, "r") or http.get(source)
local response = file.getResponseCode and file.getResponseCode() or 200
if (response < 200 or response >= 400) then return display("Failed to download file") end

local json = file.readAll()
if (file.close) then file.close() end
local data = textutils.unserializeJSON(json, {
  parse_empty_array = false,
  parse_null = false
})
if (not data or #data == 0) then return display("No data") end


