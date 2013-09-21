turtlecraft.fuel = {};

(function()
	local internal = {
		fuelSlot = 1,
		fuelPerBurn = 0,
		itemsPerBurn = 1
	};
	
	internal.getRefuelCount = function()
		return turtle.getItemCount(internal.fuelSlot);
	end
	
	internal.burn = function()
		turtle.select(internal.fuelSlot);
		local preburn = turtle.getFuelLevel();
		if (not turtle.refuel(internal.itemsPerBurn)) then return false; end
		local postburn = turtle.getFuelLevel();
		internal.fuelPerBurn = postburn - preburn;
		return true;
	end
	
	turtlecraft.fuel.estimateRemaining = function() 
		local current = turtle.getFuelLevel();
		local refuels = internal.getRefuelCount();
		local unburned = refuels * internal.fuelPerBurn;
		return current + unburned;
	end
	
	turtlecraft.fuel.require = function(count) 
		if (count == nil) then count = 1; end
		while (turtle.getFuelLevel() < count) do
			if (not internal.burn()) then
				print("Turtle ran out of fuel! Please put more in slot 1");
				while (not internal.burn()) do
					sleep(5);
				end
			end
		end
	end
end)();