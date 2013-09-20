if (turtlecraft ~= nil) then 
	error("A conflicting version of turtle craft exists or another script has registered 'turtlecraft'"); 
end

turtlecraft = {};
turtlecraft.version = 0.01;
turtlecraft.directory = "turtlecraft_data/";

turtlecraft.math = {};
turtlecraft.math.round = function(number)
	if (number % 1 < 0.5) then
		return math.floor(number);
	else
		return math.ceil(number);
	end
end

turtlecraft.input = {};
turtlecraft.input.readKey = function()
	local event, code = os.pullEvent("key");
	if (event ~= "key") then return nil; end
	return code;
end