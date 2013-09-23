if (turtlecraft ~= nil) then 
	error("A conflicting version of turtle craft exists or another script has registered 'turtlecraft'"); 
end

turtlecraft = {};
turtlecraft.version = 0.01;
turtlecraft.directory = "turtlecraft_data/";
if (not fs.exists("turtlecraft_data")) then fs.makeDir("turtlecraft_data"); end

