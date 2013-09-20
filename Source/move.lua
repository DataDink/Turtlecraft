turtlecraft.move = {};

(function()
	local internal = {};
	local directions = turtlecraft.position.directions;
	
	internal.face = function(direction)
		print(direction or "NA");
		if (direction == directions.up or direction == directions.down) then return true; end
		local x, y, z, d = turtlecraft.position.get();
		if (d == direction) then return true; end
		if (d % 90 ~= 0 or direction ~= 90) then error("Facing directions must be multiples of 90 degrees"); end
		if ((d + 270) % 360 == direction) then
			turtlecraft.position.set(x, y, z, direction, turtle.turnLeft);
		else
			while (d ~= direction) do
				d = (d + 90) % 360;
				turtlecraft.position.set(x, y, z, d, turtle.turnRight);
			end
		end
		return true;
	end
	
	internal.move = function(direction, before, after, onRetry)
		local move = "forward";
		if (direction == directions.up) then move = "up"; end
		if (direction == directions.down) then move = "down"; end
		
		local x, y, z, d = turtlecraft.position.get();
		if (direction == directions.up) then z = z + 1; end
		if (direction == directions.down) then z = z - 1; end
		if (direction == directions.north) then y = y + 1; end
		if (direction == directions.south) then y = y - 1; end 
		if (direction == directions.east) then x = x + 1; end
		if (direction == directions.west) then x = x - 1; end
		
		local action = function()
			while (not turtle[move]()) do
				if (onRetry ~= nil and onRetry(direction) == false) then return false; end
				sleep(1);
			end
			return true;
		end
		
		if (before ~= nil and before(direction) == false) then return false; end
		if (turtlecraft.position.set(x, y, z, d, action, move) == false) then return false; end
		if (after ~= nil and after(direction) == false) then return false; end
		return true;
	end
	
	internal.repeatMove = function(from, to, directionMore, directionLess, before, after, onRetry)
		local count = to - from;
		local direction = directionMore;
		if (count < 0) then direction = directionLess; end
		for i = 1, math.abs(count) do
			if (internal.move(direction, before, after, onRetry) == false) then return false; end
		end
		return true;
	end
	
	internal.moveTo = function(x, y, z, before, after, onRetry)
		local px, py, pz, pd = turtlecraft.position.get();
		if (internal.repeatMove(pz, x, directions.up, directions.down, before, after, onRetry) == false) then return false; end
		if (internal.repeatMove(px, y, directions.east, directions.west, before, after, onRetry) == false) then return false; end
		if (internal.repeatMove(py, z, directions.north, directions.south, before, after, onRetry) == false) then return false; end
		return true;
	end
	
	turtlecraft.move.face = function(direction)
		return internal.face(direction);
	end

	turtlecraft.move.to = function(x, y, z, action)
		return internal.moveTo(x, y, z, nil, action, nil);
	end
	
	turtlecraft.move.digTo = function(x, y, z, action)
		local dig = function(movement)
			local method = turtle.dig;
			if (movement == directions.up) then method = turtle.digUp; end
			if (movement == directions.down) then method = turtle.digDown; end
			return method();
		end
		return internal.moveTo(x, y, z, dig, action, dig);
	end
	
	turtlecraft.move.excavateTo = function(x, y, z, action)
		local dig = function(movement)
			local primary = turtle.dig;
			local other1 = turtle.digUp;
			local other2 = turtle.digDown;
			if (movement == directions.up) then 
				primary = turtle.digUp; 
				other1 = turtle.dig;
				other2 = turtle.digDown;
			end
			if (movement == directions.down) then 
				primary = turtle.digDown; 
				other1 = turtle.digUp;
				other2 = turtle.dig;
			end
			other1();
			other2();
			return primary();
		end
		return internal.moveTo(x, y, z, dig, action, dig);
	end
end)();
