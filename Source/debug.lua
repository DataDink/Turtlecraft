local files = http.get("https://raw.github.com/DataDink/Turtlecraft/master/Source/manifest");
for file in files.readLine do
	print('file');
	local exec, err = loadstring(http.get("https://raw.github.com/DataDink/Turtlecraft/master/Source/" .. file).readAll());
	if (err ~= nil) then error(err); end
	exec();
end