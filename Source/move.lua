turtlecraft.move = {};

(function()
	local internal = {};
	local directions = turtlecraft.position.directions;
	
	internal.face = function(direction)
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
		if (direction == directions.down then move = "down"; end
		
		local x, y, z, d = turtlecraft.position.get();
		if (direction == directions.up) then z = z + 1; end
		if (direction == directions.down) then z = z - 1; end
		if (direction == directions.north) then y = y + 1; end
		if (direction == directions.south) then y = y - 1; end 
		if (direction == directions.east) then x = x + 1; end
		if (direction == directions.west) then x = x - 1; end
		
		local action = function()
			while (not turtle[move]()) do
				if (onRetry ~= nil and onRetry() == false) then return false; end
				sleep(1);
			end
			return true;
		end
		
		if (before ~= nil and before() == false) then return false; end
		if (turtlecraft.position.set(x, y, z, d, action, move) == false) then return false; end
		if (after ~= nil and after() == false) then return false; end
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
		local current = {};
		local current.x, current.y, current.z, current.d = turtlecraft.position.get();
		if (internal.repeatMove(z, current.z, directions.up, directions.down, before, after, onRetry) == false) then return false; end
		if (internal.repeatMove(x, current.x, directions.east, directions.west, before, after, onRetry) == false) then return false; end
		if (internal.repeatMove(y, current.y, directions.north, directions.south, before, after, onRetry) == false) then return false; end
		return true;
	end

	turtlecraft.move.to = function(x, y, z, action)
		return internal.moveTo(x, y, z, nil, action, nil);
	end
	
	turtlecraft.move.digTo = function(x, y, z, action)
		return internal.moveTo(x, y, z, turtle.dig, action, turtle.dig);
	end
	
	turtlecraft.move.excavateTo = function(x, y, z, action)
		local dig = function() {
			-- TODO - this needs to know what direction it's going - so do the others.
		}
	end
end)();
