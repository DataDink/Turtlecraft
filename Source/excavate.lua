turtlecraft.excavate = {};

turtlecraft.scope = function() 

	local position = turtlecraft.position;
	local directions = position.directions;
	local terminal = turtlecraft.term;

	local inventory = {};
	local plot = {};
	local move = {};
	
	plot.path = turtlecraft.directory .. "excavate.data";
	plot.init = function(forward, left, right, up, down, forwardOffset, sidewayOffset, verticalOffset)
		forwardOffset = math.max(0, forwardOffset or 0);	
		sidewayOffset = (sidewayOffset or 0);	
		verticalOffset = (verticalOffset or 0);	

		local x, y, z, d = position.get();
		plot.home = {x = x, y = y, z = z, d = (d + 180) % 360};
		plot.step = {x = 1, y = 1, z = -3};
		plot.min = {x = x, y = y, z = z - math.abs(down) + 1 + verticalOffset};
		plot.max = {x = x, y = y, z = z + math.abs(up) - 1 + verticalOffset};
		
		if (d == directions.north) then
			plot.max.y = plot.max.y + math.abs(forward) + forwardOffset;
			plot.min.x =  plot.min.x - math.abs(left) + sidewayOffset;
			plot.max.x = plot.max.x + math.abs(right) + sidewayOffset;
		elseif (d == directions.south) then
			plot.min.y = plot.min.y - math.abs(forward) + forwardOffset;
			plot.min.x =  plot.min.x - math.abs(right) + sidewayOffset;
			plot.max.x = plot.max.x + math.abs(left) + sidewayOffset;
		elseif (d == directions.east) then
			plot.max.x = plot.max.x + math.abs(forward) + forwardOffset;
			plot.min.y = plot.min.y - math.abs(right) + sidewayOffset;
			plot.max.y = plot.max.y + math.abs(left) + sidewayOffset;
		else
			plot.min.x = plot.min.x - math.abs(forward) + forwardOffset;
			plot.min.y = plot.min.y - math.abs(left) + sidewayOffset;
			plot.max.y = plot.max.y + math.abs(right) + sidewayOffset;
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
			if (plot[index] == nil) then plot[index] = {}; end
			local target = plot[index];
			target.x = tonumber(reader() or 0);
			target.y = tonumber(reader() or 0);
			target.z = tonumber(reader() or 0);
			target.d = tonumber(reader() or "");
		end
		
		fs.delete(plot.path);
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
					terminal.clear('Excavate', '(Press Q to cancel)');
					terminal.write(1, 5, 'Unable to unload inventory.');
					terminal.write(1, 6, 'Will resume when issue is resolved.');
					while(not turtle.drop()) do
						sleep(1);
					end
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
		fs.delete(plot.path);
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
		
		local movemethod = turtlecraft.move.excavateTo;
		local target = {x = plot.progress.x, y = plot.progress.y, z = plot.progress.z};
		target.x = target.x + plot.step.x;
		if (target.x > plot.max.x or target.x < plot.min.x) then
			plot.step.x = -plot.step.x;
			target.x = target.x + plot.step.x;
			target.y = plot.progress.y + plot.step.y;
			if (target.y > plot.max.y or target.y < plot.min.y) then
				plot.step.y = -plot.step.y;
				target.y = target.y + plot.step.y;
				target.z = target.z + plot.step.z;
				movemethod = turtlecraft.move.digTo;
				turtle.digUp(); -- little hack
				if (target.z == plot.min.z - 1 or target.z == plot.min.z - 2) then 
					target.z = plot.min.z; 
				end
				if (target.z < plot.min.z) then
					move.finish();
					return false;
				end
			end
		end
		
		if (not movemethod(target.x, target.y, target.z)) then 
			print("move failed");
			local x, y, z, d = turtlecraft.position.get();
			if (x == plot.progress.x and y == plot.progress.y and z == plot.progress.z) then
				print("Unable to dig further");
				move.finish();
				return false;
			end
		end
		plot.update();
		return true;
	end
	move.start = function(forward, left, right, up, down, forwardOffset, sidewayOffset, verticalOffset)
		plot.init(forward, left, right, up, down, forwardOffset, sidewayOffset, verticalOffset);
		turtlecraft.term.write(1, 5, "Press Q to cancel");
		turtlecraft.input.escapeOnKey(16, function()
			while (move.next()) do
				sleep(0.001);
			end
		end);
		plot.reset();
	end
	
	-- UI
	local readNumber = function(x, y)
		term.setCursorPos(x, y);
		local value = tonumber(read() or "");
		if (value == nil) then return 0; end
		return value;
	end
	
	if (plot.recover()) then
		if (not terminal.notifyResume("excavating")) then
			terminal.clear("Excavate");
			terminal.write(1, 5, "Excavate cancelled...");
			sleep(3);
			return;
		end
		terminal.clear("Excavate");
		terminal.write(1, 5, "Resuming excavate...");
		term.setCursorPos(1, 6);
		while (move.next()) do
			sleep(0.001);
		end
	end
	
	turtlecraft.excavate.start = function()
		terminal.clear("Excavate");
		terminal.write(1, 4, "How far forward?");
		local forward = readNumber(18, 4);
		if (forward == 0) then return false; end
		terminal.write(1, 4, "How far left?");
		local left = readNumber(15, 4);
		terminal.write(1, 4, "How far right?");
		local right = readNumber(16, 4);
		if (left == 0 and right == 0) then return false; end
		terminal.write(1, 4, "How far up?");
		local up = readNumber(13, 4);
		terminal.write(1, 4, "How far down?");
		local down = readNumber(15, 4);
		if (up == 0 and down == 0) then return false; end
		
		local offsetForward = 0;
		local offsetHorz = 0;
		local offsetVert = 0;
		terminal.write(1, 4, "Would you like to offset the dig? (y, n)");
		if (read() == 'y') then
			terminal.clear("Excavate");
			terminal.write(1, 4, "Forward offset: ");
			offsetForward = readNumber(16, 4);
			terminal.write(1, 4, "Sideway offset: ");
			offsetHorz = readNumber(19, 4);
			terminal.write(1, 4, "Vertical offset: ");
			offsetVert = readNumber(17, 4);
		end
		
		terminal.clear("Excavate");
		move.start(forward, left, right, up, down, offsetForward, offsetHorz, offsetVert);
		terminal.clear("Excavate");
		terminal.write(1, 4, "Digging is complete.");
		terminal.write(1, 5, "Press any key to continue.");
		term.setCursorPos(0, 0);
		turtlecraft.input.readKey(10);
	end
	
	turtlecraft.excavate.debug = {};
	turtlecraft.excavate.debug.start = function(forward, left, right, up, down)
		move.start(forward, left, right, up, down);
	end
end
turtlecraft.scope();	
