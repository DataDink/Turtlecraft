if (turtlecraft ~= nil) then 
	error("A conflicting version of turtle craft exists or another script has registered 'turtlecraft'"); 
end

turtlecraft = {};
turtlecraft.directory = "turtlecraft_data/";