local manifest = http.get("https://raw.github.com/DataDink/Turtlecraft/master/Source/manifest");
print(manifest);
print(manifest.readLine);
local fileName = manifest.readLine();
while (fileName ~= nil) do
	print(fileName);
	local file = http.get("https://raw.github.com/DataDink/Turtlecraft/master/Source/" .. fileName).readAll();
	local exec, err = loadstring(file);
	if (err ~= nil) then error(err); end
	exec();
	fileName = manifest.readLine();
end