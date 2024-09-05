local file = http.get("https://raw.github.com/DataDink/Turtlecraft/master/Current/turtlecraft.lua").readAll();
local exec, err = loadstring(file);
if (err ~= nil) then error(err); end
exec();