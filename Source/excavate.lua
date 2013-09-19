turtlecraft.excavate = {};

(function() 

	local position = turtlecraft.position;
	local directions = position.directions;

	local inventory = {};
	local marker = {};
	local move = {};
	
	marker.init = function()
		local x, y, z, d = position.get();
		marker.startedAt = {x = x, y = y, z = z, d = d};
		marker.returnTo = {x = x, y = y, z = z, d = d};
		marker.forward = d;
		marker.right = (d + 90) % 360;
		marker.backward = (d + 180) % 360;
		marker.left = (d + 270) % 360;
	end
	marker.init();

	marker.mark = function() 
		local x, y, z = position.get();
		marker.returnTo.x = x; 
		marker.returnTo.y = y; 
		marker.returnTo.z = z; 
	end
	
	marker.calcReturn = function()
		local x, y, z, d = position.get();
		local distx = math.abs(marker.startedAt.x - x);
		local disty = math.abs(marker.startedAt.y - y);
		local distz = math.abs(marker.startedAt.z - z);
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
		turtlecraft.move.face(marker.backward);
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
		marker.mark();
		turtlecraft.move.digTo(marker.startedAt.x, marker.startedAt.y, marker.startedAt.z);
		callback();
		turtlecraft.move.face(marker.forward);
		turtlecraft.move.digTo(marker.returnTo.x, marker.returnTo.y, marker.returnTo.z);
	end
	move.finish = function()
		turtlecraft.move.digTo(marker.startedAt.x, marker.startedAt.y, marker.startedAt.z);
		turtlecraft.move.face(marker.backward);
		inventory.unload();
		turtle.select(1);
		turtle.drop();
		turtlecraft.move.face(directions.forward);
	end
	move.excavate = function(forward, left, right, up, down)
		local aMin = 0;
		local aMax = marker.startedAt.y + math.abs(forward);
		local xmin = marker.startedAt.x - math.abs(left);
		local xmax = marker.startedAt.x + math.abs(right);
		local zmin = marker.startedAt.z - math.abs(down);
		local zmax = marker.startedAt.z + math.abs(up);
		
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
