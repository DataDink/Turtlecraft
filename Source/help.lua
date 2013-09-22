turtlecraft.help = {}

(function()
	local continue = function()
		print("Press any key to read more...");
		turtlecraft.input.readKey();
		term.clear();
	end

	local show = function(text)
		local width, height = term.getSize();
		term.clear();
		
		local row = 1;
		local rowText = "";
		local lines = string.gmatch(text, "[^\r\n]+");
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
		show("test test test test test test test test test test test test test\r\n test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test ");
	end
end)();