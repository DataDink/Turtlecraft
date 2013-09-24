turtlecraft.input = {};
turtlecraft.input.readKey = function(timeout)
	if (timeout ~= nil) then os.startTimer(timeout); end
	local event = ""; local code = 0;
	repeat event, code = os.pullEvent(); until (event == "key" or event == "timer");
	if (event == "timer") then return nil; end
	return code;
end
turtlecraft.input.escapeOnKey = function(keyCode, delegate)
	local getKey = function() 
		while true do
			local event, code = os.pullEvent("key");
			if (code == keyCode) then return; end
		end
	end
	parallel.waitForAny(getKey, delegate);
end

turtlecraft.term = {};
turtlecraft.term.write = function(column, row, text)
	term.setCursorPos(column, row);
	term.clearLine();
	term.write(text);
end
turtlecraft.term.clear = function(title, footer)
	term.clear();
	local width, height = term.getSize();
	local headerText = "Turtlecraft v" .. turtlecraft.version;
	if (title ~= nil) then headerText = headerText .. " - " .. title; end
	turtlecraft.term.write(1, 1, headerText);
	local underline = "";
	for i = 1, width do
		underline = underline .. "=";
	end
	turtlecraft.term.write(1, 2, underline);
	if (footer ~= nil) then
		turtlecraft.term.write(1, height, footer);
	end
end
turtlecraft.term.scrolled = function(column, row, scrollTo, text)
	local _, height = term.getSize();
	local scroll = math.max(0, scrollTo - height + 1);
	local display = height - 5;
	local top = 3;
	local position = row - scroll;
	if (position < 1 or position > display) then return; end
	turtlecraft.term.write(1, position + top, text);
end
turtlecraft.term.notifyResume = function(ofWhat)
	if (ofWhat == nil) then ofWhat = "previous function"; end
	turtlecraft.term.clear();
	turtlecraft.term.write(1, 4, "Resuming: " .. ofWhat);
	turtlecraft.term.write(1, 5, "in 15 seconds.");
	turtlecraft.term.write(1, 6, "Press any key to cancel.");
	local code = turtlecraft.input.readKey(15);
	turtlecraft.term.clear();
	return code == nil;
end