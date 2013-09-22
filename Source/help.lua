turtlecraft.help = {}

(function()
	local continue = function()
		print("Press any key to read more...");
		turtlecraft.input.readKey();
		term.clear();
		term.setCursorPos(1, 1);
	end

	local show = function(text)
		local width, height = term.getSize();
		term.clear();
		term.setCursorPos(1, 1);
		
		local row = 1;
		local rowText = "";
		local lines = string.gmatch(text, "[^\n]+");
		for line in lines do
			local words = string.gmatch(text, "%S+");
			for word in words do
				local word = word .. " ";
				local wordLength = string.len(word);
				local rowLength = string.len(rowText);
				if (rowLength + wordLength >= width - 1) then
					print(rowText);
					rowText = "";
					row = row + 1;
					if (row >= (height - 1)) then
						continue();
						row = 1;
					end
				end
				rowText = rowText .. word;
			end
			print(rowText);
			rowText = "";
			row = row + 1;
			if (row >= (height - 1)) then
				continue();
				row = 1;
			end
		end
		continue();
	end
	
	turtlecraft.help.general = function()
		local text = "Turtlecraft is a menu-driven system that will help you utilize your turtle for various creating, digging, and collection functions.\r\n";
		text = text .. "Select 'Dig functions' to excavate, fill/clear areas, or 'eat'.\r\n";
		text = text .. "Select 'Build functions' to have your turtle help you create 2d and 3d shapes.\r\n";
		text = text .. "There is a whole world of things you can make your turtle do. Turtlecraft will only help you with these few things.\r\n";
		show(text);
	end
end)();