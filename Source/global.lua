if (turtlecraft ~= nil) then 
	error("A conflicting version of turtle craft exists or another script has registered 'turtlecraft'"); 
end

turtlecraft = {};
turtlecraft.version = 0.01;
turtlecraft.directory = "turtlecraft_data/";
if (not fs.exists("turtlecraft_data")) then fs.makeDir("turtlecraft_data"); end

turtlecraft.math = {};
turtlecraft.math.round = function(number)
	if (number % 1 < 0.5) then
		return math.floor(number);
	else
		return math.ceil(number);
	end
end

turtlecraft.input = {};
turtlecraft.input.readKey = function(timeout)
	if (timeout ~= nil) then os.startTimer(timeout); end
	local event = ""; local code = 0;
	repeat event, code = os.pullEvent(); until (event == "key" or event == "timer");
	if (event == "timer") then return nil; end
	return code;
end

turtlecraft.term = {};
turtlecraft.term.write = function(column, row, text)
	term.setCursorPos(columnd, row);
	term.clearLine();
	term.write(text);
end
turtlecraft.term.clear = function(title, footer)
	term.clear();
	local width, height = term.getSize();
	local headerText = "Turtlecraft v" .. turtlecraft.version;
	if (title ~= nil) then headerText = headerText .. " - " .. title;
	turtlecraft.term.write(1, 1, headerText);
	local underline = "";
	for i = 1, width do
		underline = underline + "=";
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
	local top = 4;
	local position = row - scroll;
	if (position < 1 or position > display) then return; end
	turtlecraft.term(1, position + top, text);
end
turtlecraft.term.notifyResume = function(ofWhat) {
	turtlecraft.term.clear();
	local text = "The turtle will resume";
	if (ofWhat ~= nil) then text = text .. " " .. ofWhat;
	text = text .. " in 15 seconds.";
	turtlecraft.term.write(1, 4, text);
	turtlecraft.term.write(1, 5, "Press any key to cancel.");
	local code = turtlecraft.input.readKey(15);
	turtlecraft.term.clear();
	return code == nil;
}