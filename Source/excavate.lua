turtlecraft.excavate = {};

(function() 

	local position = turtlecraft.position;
	local directions = position.directions;

	local inventory = {};
	local move = {};
	local plot = {};
	
	plot.path = turtlecraft.directory .. "excavate.data";
	plot.init = function(forward, left, right, up, down)
		local x, y, z, d = position.get();
		plot.home = {x = x, y = y, z = z, d = (d + 180) % 360};
		plot.stepX = 1;
		plot.stepY = 1;
		plot.stepZ = -3;
		
		plot.maxZ = z + math.abs(up);
		plot.minZ = z - math.abs(down);
		plot.maxX = x; plot.minX = x; 
		plot.maxY = y; plot.minY = y;
		if (d == directions.north) then
			plot.maxY = plot.maxY + math.abs(forward);
			plot.minX =  plot.minX - math.abs(left);
			plot.maxX = plot.maxX + math.abs(right);
		elseif (d == directions.south) then
			plot.minY = plot.minY - math.abs(forward);
			plot.minX =  plot.minX - math.abs(right);
			plot.maxX = plot.maxX + math.abs(left);
		elseif (d == directions.east) then
			plot.maxX = plot.maxX + math.abs(forward);
			plot.minY = plot.minY - math.abs(left);
			plot.maxY = plot.maxY + math.abs(right);
		else
			plot.minX = plot.minX - math.abs(forward);
			plot.minY = plot.minY - math.abs(right);
			plot.maxY = plot.maxY + math.abs(left);
		end
		
		plot.progress = {x = plot.minX, y = plot.minY, z = plot.maxZ};
	end
	plot.calcReturn = function()
		local x, y, z, d = position.get();
		local distx = math.abs(plot.home.x - x);
		local disty = math.abs(plot.home.y - y);
		local distz = math.abs(plot.home.z - z);
		return distx + disty + distz + 5;
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
		turtlecraft.move.face(plot.backward);
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
		plot.mark();
		turtlecraft.move.digTo(plot.home.x, plot.home.y, plot.home.z);
		callback();
		turtlecraft.move.face(plot.forward);
		turtlecraft.move.digTo(plot.returnTo.x, plot.returnTo.y, plot.returnTo.z);
	end
	move.finish = function()
		turtlecraft.move.digTo(plot.home.x, plot.home.y, plot.home.z);
		turtlecraft.move.face(plot.backward);
		inventory.unload();
		turtle.select(1);
		turtle.drop();
		turtlecraft.move.face(directions.forward);
	end
	move.plot = function (forward, left, right, up, down)
		local x, y, z, d = turtlecraft.position.get();
		local plot = {};
		plot.forward = d;
		plot.right = (d + 90) % 360;
		plot.backward = (d + 180) % 360;
		plot.left = (d + 270) % 360;
	end
	move.excavate = function(forward, left, right, up, down)

	
		local y = marker.startedAt.y;
		local ystep = 1
		
		local row = 0;
		local rowStep = y / math.abs(y);
		local rowMax = math.max(0, y);
		local rowMin = math.min(0, y);
		
		local column = 0;
		local columnStep = x / math.abs(x);
		local columnMax = math.max(0, x);
		local columnMin = math.min(0, x);
		
		local layer = 0;
		local layerStart = z / math.abs(z);
		local layerStep = layerStart * 3;
		local layerMax = math.max(0, z);
		local layerMin = math.min(0, z);
		
		for layer = layerStart, z, layerStep do
			move.face(directions.forward);
			if (not move.to(position.current.x, position.current.y, layer)) then
				print("Returning: Reached unbreakable blocks");
				move.finish();
				return;
			end
			
			while (row >= rowMin and row <= rowMax) do
				while (column >= columnMin and column <= columnMax) do
					
					if (fuel.needsRefuel()) then
						print("Returning for refuel...");
						move.home(function() 
							print("Waiting for more fuel in slot 1.");
							turtle.refuel();
							while (not turtle.refuel(1)) do
								sleep(3);
								turtle.select(1);
							end
							fuel.initialize();
							print("Continuing");
						end);
					end
					
					if (inventory.needsUnload()) then
						print("Returning for unload...");
						move.home(function() 
							inventory.unload();
							print("Continuing");
						end);
					end
					
					if (not move.to(column, row, layer)) then
						print("Returning: Reached unbreakable blocks");
						return move.finish();
					end
					
					column = column + columnStep;
				end
				if (column > columnMax) then column = columnMax; end
				if (column < columnMin) then column = columnMin; end
				columnStep = -columnStep;
				row = row + rowStep;
			end
			if (row > rowMax) then row = rowMax; end
			if (row < rowMin) then row = rowMin; end
			rowStep = -rowStep;				
		end
		
		print("Returning: Mission complete");
		move.finish();
	end

	excavator.start = function(x, y, z)
		move.excavate(x, y, z);
	end
end)();	
