turtlecraft.menu = {}

turtlecraft.menu.dig = {
	title = "Dig Functions",
	action = {}
};
turtlecraft.menu.dig.action.excavate = {
	title = "Excavator / Quarry",
	action = turtlecraft.excavate.start
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
		print(item);
		return item;
	end
	
	local drawMenu = function()
		term.clear();
		local width, height = term.getSize();
		writeLine(1, 1, "Turtlecraft v" .. turtlecraft.version .. ".");
		writeLine(1, 2, "====================");
		writeLine(1, height, "--Use up/down and enter/left--");
		
		local displayCount = height - 4;
		local startIndex = math.max(0, selectedIndex - displayCount);
		local endIndex = startIndex + displayCount;
		local index = 1;
		local menu = currentMenu();
		for k, item in pairs(menu) do
			if (index > startIndex and index <= endIndex) then
				local text = item.title;
				if (index == selectedIndex) then text = ">" .. text .. "<"; end
				writeLine(1, index - startIndex + 3, text);
			end
			index = index + 1;
		end
	end
	
	local selectItem = function()
		local menu = currentMenu();
		term.clear();
		writeLine(1, 1, selectedIndex);
		writeLine(1, 2, menu);
		writeLine(1, 3, table.getn(menu));
		local item = menu[selectedIndex].action;
		if (typeof(item) == "function") then
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