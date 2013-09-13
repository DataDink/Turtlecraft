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
			turtlecraft.position.set(x, y, z, direction);
			return turtle.turnLeft();
		else
			while (d ~= direction) do
				d = (d + 90) % 360;
				turtlecraft.position.set(x, y, z, d);
				if (not turtle.turnRight()) then return false; end
			end
		end
		return true;
	end
	
	internal.move = function(direction, before, after, onRetry)
		if (not internal.face(direction)) then return false; end
		turtlecraft.fuel.require(1);
		local move = turtle.north;
		if (direction == directions.up) then move = turtle.up; end
		if (direction == directions.down then move = turtle.down; end
		if (before ~= nil) then before(); end
		
		local x, y, z, d = turtlecraft.position.get();
		if (direction == directions.up) then z = z + 1; end
		if (direction == directions.down) then z = z - 1; end
		if (direction == directions.north) then y = y + 1; end
		if (direction == directions.south) then y = y - 1; end 
		if (direction == directions.east) then x = x + 1; end
		if (direction == directions.west) then x = x - 1; end
		
	end
end)();
