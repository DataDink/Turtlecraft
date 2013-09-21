turtlecraft.menu = {}
turtlecraft.menu[1] = {
	title = "Dig functions",
	action = {};
}

	turtlecraft.menu[1].action = {};
	turtlecraft.menu[1].action[1] = {
		title = "Excavate",
		action = turtlecraft.excavate.start
	};
	turtlecraft.menu[1].action[2] = {
		title = "Eat Area",
		action = function() print("NYI"); read(); end
	};
	turtlecraft.menu[1].action[3] = {
		title = "Fill Area",
		action = function() print("NYI"); read(); end
	};
	turtlecraft.menu[1].action[4] = {
		title = "Empty Area",
		action = function() print("NYI"); read(); end
	};


(function()
	local selectedIndex = 1;
	local history = {};
	table.insert(history, turtlecraft.menu);
	
	local writeLine = function(x, y, text)
		term.setCursorPos(x, y);
		term.clearLine();
		term.write(text);
	end
	
	local currentMenu = function()
		local item = history[table.getn(history)];
		return item;
	end
	
	local drawMenu = function()
		term.clear();
		local width, height = term.getSize();
		writeLine(1, 1, "Turtlecraft v" .. turtlecraft.version .. ".");
		writeLine(1, 2, "====================");
		writeLine(1, height, "**Use up/down and enter/left**");
		
		local displayCount = height - 4;
		local startIndex = math.max(0, selectedIndex - displayCount);
		local endIndex = startIndex + displayCount;
		local menu = currentMenu();
		for index, item in ipairs(menu) do
			if (index > startIndex and index <= endIndex) then
				local text = item.title;
				if (index == selectedIndex) then text = ">" .. text .. "<"; 
				else text = " " .. text; end
				writeLine(1, index - startIndex + 3, text);
			end
		end
	end
	
	local selectItem = function()
		local menu = currentMenu();
		local item = menu[selectedIndex].action;
		if (type(item) == "function") then
			item();
		else
			table.insert(history, item);
		end
	end
	
	local goBack = function()
		if (table.getn(history) > 1) then
			selectedIndex = 1;
			table.remove(history);
		end
	end
	
	local downArrow = function()
		local menu = currentMenu();
		if (selectedIndex < table.getn(menu)) then
			selectedIndex = selectedIndex + 1;
		end
	end
	
	local upArrow = function()
		if (selectedIndex > 1) then
			selectedIndex = selectedIndex - 1;
		end
	end
	
	if (not turtlecraft.position.isInSync()) then
		term.clear();
		writeLine(1, 1, "The turtle's position has gotten out of sync.");
		writeLine(1, 2, "If there was a function in progress it has likely been cancelled.");
		writeLine(1, 3, "Press any key to continue");
		local _, _, _, d = turtlecraft.position.get();
		turtlecraft.position.set(0, 0, 0, d);
		turtlecraft.input.readKey();
	end
	
	while (true) do
		drawMenu();
		sleep(0.01);
		local key = turtlecraft.input.readKey();
		if (key == 28) then selectItem(); end
		if (key == 200) then upArrow(); end
		if (key == 208) then downArrow(); end
		if (key == 203) then goBack(); end
	end
end)();