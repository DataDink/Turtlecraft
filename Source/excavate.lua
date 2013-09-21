turtlecraft.excavate = {};

(function() 

	local position = turtlecraft.position;
	local directions = position.directions;

	local inventory = {};
	local plot = {};
	local move = {};
	local ui = {};
	
	plot.path = turtlecraft.directory .. "excavate.data";
	plot.init = function(forward, left, right, up, down)
		local x, y, z, d = position.get();
		plot.home = {x = x, y = y, z = z, d = (d + 180) % 360};
		plot.step = {x = 1, y = 1, z = -3};
		plot.min = {x = x, y = y, z = z - math.abs(down)};
		plot.max = {x = x, y = y, z = z + math.abs(up)};

		if (d == directions.north) then
			plot.max.y = plot.max.y + math.abs(forward);
			plot.min.x =  plot.min.x - math.abs(left);
			plot.max.x = plot.max.x + math.abs(right);
		elseif (d == directions.south) then
			plot.min.y = plot.min.y - math.abs(forward);
			plot.min.x =  plot.min.x - math.abs(right);
			plot.max.x = plot.max.x + math.abs(left);
		elseif (d == directions.east) then
			plot.max.x = plot.max.x + math.abs(forward);
			plot.min.y = plot.min.y - math.abs(left);
			plot.max.y = plot.max.y + math.abs(right);
		else
			plot.min.x = plot.min.x - math.abs(forward);
			plot.min.y = plot.min.y - math.abs(right);
			plot.max.y = plot.max.y + math.abs(left);
		end
		plot.progress = {x = plot.min.x, y = plot.min.y, z = plot.max.z};
	end
	plot.update = function()
		local x, y, z, d = position.get();
		plot.progress = {x = x, y = y, z = z};
		local file = fs.open(plot.path, "w");
		file.writeLine(plot.home.x .. "," .. plot.home.y .. "," .. plot.home.z .. "," .. plot.home.d);
		file.writeLine(x .. "," .. y .. "," .. z);
		file.writeLine(plot.min.x .. "," .. plot.min.y .. "," .. plot.min.z);
		file.writeLine(plot.max.x .. "," .. plot.max.y .. "," .. plot.max.z);
		file.writeLine(plot.step.x .. "," .. plot.step.y .. "," .. plot.step.z);
		file.close();
	end
	plot.reset = function()
		fs.delete(plot.path);
		local x, y, z, d = position.get();
		plot.home = {x = x, y = y, z = z, d = (d + 180) % 360};
		plot.progress = {x = x, y = y, z = z};
		plot.min = {x = x, y = y, z = z};
		plot.max = {x = x, y = y, z = z};
		plot.step = {x = 1, y = 1, z = -3};
	end
	plot.recover = function()
		if (not fs.exists(plot.path)) then return false; end
		local file = fs.open(plot.path, "r");
		local home = file.readLine();
		local progress = file.readLine();
		local boundsmin = file.readLine();
		local boundsmax = file.readLine();
		local resume = file.readLine();
		file.close();
		if ((not position.isInSync()) or home == nil or progress == nil or boundsmin == nil or boundsmax == nil or resume == nil) then 
			print("Warning: Unable to resume dig");
			return false; 
		end
		local valuePattern = "[^,]+";
		
		local setters = {
			home = home,
			progress = progress,
			min = boundsmin,
			max = boundsmax,
			step = resume
		};
		
		for index, data in pairs(setters) do
			local reader = string.gmatch(data, valuePattern);
			local target = plot[index];
			target.x = tonumber(reader() or 0);
			target.y = tonumber(reader() or 0);
			target.z = tonumber(reader() or 0);
			target.d = tonumber(reader() or "");
		end
		
		return true;
	end
	plot.calcDistance = function(x, y, z)
		local fx, fy, fz, fd = position.get();
		local distx = math.abs(fx - x);
		local disty = math.abs(fy - y);
		local distz = math.abs(fz - z);
		return distx + disty + distz + 5;
	end
	plot.calcReturn = function()
		return plot.calcDistance(plot.home.x, plot.home.y, plot.home.z);
	end
	
	-- Inventory
	inventory.calcRemainingSlots = function() 
		local count = 0;
		for i = 2, 16 do
			if (turtle.getItemCount(i) == 0) then count = count + 1; end
		end
		return count;
	end
	inventory.needsUnload = function() return inventory.calcRemainingSlots() == 0; end
	inventory.unload = function()
		turtlecraft.move.face(plot.home.d);
		for i = 2, 16 do
			if (turtle.getItemCount(i) > 0) then
				turtle.select(i);
				if (not turtle.drop()) then
					error("Fatal Error: Can't unload inventory.");
				end
			end				
		end
	end
	
	-- Movement
	move.home = function(callback)
		turtlecraft.move.digTo(plot.home.x, plot.home.y, plot.home.z);
		callback();
		turtlecraft.move.face((plot.home.d + 180) % 360);
		turtlecraft.move.digTo(plot.progress.x, plot.progress.y, plot.progress.z);
	end
	move.finish = function()
		turtlecraft.move.digTo(plot.home.x, plot.home.y, plot.home.z);
		turtlecraft.move.face(plot.home.d);
		inventory.unload();
		turtle.select(1);
		turtle.drop();
		turtlecraft.move.face((plot.home.d + 180) % 360);
		plot.reset();
	end
	move.next = function()
		local resumeDist = plot.calcDistance(plot.progress.x, plot.progress.y, plot.progress.z);
		local homeDist = plot.calcReturn();
		local fuel = turtlecraft.fuel.estimateRemaining();
		if (inventory.needsUnload() or fuel <= resumeDist or fuel <= homeDist) then
			move.home(function() 
				local distance = plot.calcDistance(plot.progress.x, plot.progress.y, plot.progress.z);
				turtlecraft.fuel.require(distance);
				inventory.unload();
			end);
		end
		if (not turtlecraft.move.digTo(plot.progress.x, plot.progress.y, plot.progress.z)) then
			move.finish();
			return false;
		end

		plot.progress.x = plot.progress.x + plot.step.x;
		if (plot.progress.x > plot.max.x or plot.progress.x < plot.min.x) then
			plot.step.x = -plot.step.x;
			plot.progress.x = plot.progress.x + plot.step.x;
			plot.progress.y = plot.progress.y + plot.step.y;
			if (plot.progress.y > plot.max.y or plot.progress.y < plot.min.y) then
				plot.step.y = -plot.step.y;
				plot.progress.y = plot.progress.y + plot.step.y;
				plot.progress.z = plot.progress.z + plot.step.z;
				if (plot.progress.z > plot.max.z) then
					move.finish();
					return false;
				end
			end
		end
		if (not turtlecraft.move.excavateTo(plot.progress.x, plot.progress.y, plot.progress.z)) then 
			move.finish();
			return false;
		end
		plot.update();
		return true;
	end
	move.start = function(forward, left, right, up, down)
		plot.init(forward, left, right, up, down);
		while (move.next()) do
			sleep(0.001);
		end
	end
	
	-- UI
	ui.print = function(x, y, message)
		term.setCursorPos(x, y);
		term.clearLine();
		term.write(message);
	end
	ui.readNumber = function(x, y)
		term.setCursorPos(x, y);
		local value = tonumber(read() or "");
		if (value == nil) then return 0; end
		return value;
	end
	ui.printHeader = function()
		ui.print(1, 1, "Turtlecraft v" .. turtlecraft.version .. " Excavator");
		ui.print(1, 2, "============================");
	end
	
	if (plot.recover()) then
		term.clear();
		ui.printHeader();
		ui.print(1, 3, "Resuming dig...");
		while (move.next()) do
			sleep(0.001);
		end
	end
	
	turtlecraft.excavate.start = function()
		term.clear();
		ui.printHeader();
		ui.print(1, 4, "How far forward?");
		local forward = ui.readNumber(18, 4);
		if (forward == 0) then return false; end
		ui.print(1, 4, "How far left?");
		local left = ui.readNumber(15, 4);
		ui.print(1, 4, "How far right?");
		local right = ui.readNumber(16, 4);
		if (left == 0 and right == 0) then return false; end
		ui.print(1, 4, "How far up?");
		local up = ui.readNumber(13, 4);
		ui.print(1, 4, "How far down?");
		local down = ui.readNumber(15, 4);
		if (up == 0 and down == 0) then return false; end
		
		term.clear();
		ui.printHeader();
		move.start(forward, left, right, up, down);
		term.clear();
		ui.printHeader();
		ui.print(1, 4, "Digging is complete.");
		ui.print(1, 5, "Press enter to continue.");
		term.setCursorPos(0, 0);
		read();
	end
	
	turtlecraft.excavate.debug = {};
	turtlecraft.excavate.debug.start = function(forward, left, right, up, down)
		move.start(forward, left, right, up, down);
	end
end)();	
