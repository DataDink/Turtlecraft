using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Tests.Framework;

namespace Tests
{
    public class ExcavateTests
    {
        private static void Setup(LuaEnvironment environment)
        {
            environment.Execute("test = {x = 0, y = 0, z = 0, d = 270};");
            environment.Execute("turtlecraft.position.isInSync = function() return true; end");
            environment.Execute("turtlecraft.position.get = function() return test.x, test.y, test.z, test.d; end");
            environment.Execute("turtlecraft.position.set = function(x, y, z, d, action) test.x = x; test.y = y; test.z = z; if (d ~= 'up' and d ~= 'down') then test.d = d; end return action(); end");
            environment.Execute("turtlecraft.fuel.estimateRemaining = function() return 999999; end");
            environment.FS.Files.Clear();
        }

        [Test]
        public static void MovementTest(LuaEnvironment environment)
        {
            environment.Startup();
            Setup(environment);
            environment.Execute("turtlecraft.excavate.debug.start(1, 1, 1, 1, 1);");
            var careAbout = new[] {
                "forward()", "up()", "down()", "turnLeft()", "turnRight()"
            };
            var moves = environment.Turtle.CallsMade.Where(careAbout.Contains).ToArray();
            var order = new[] {
                "turnRight()", "forward()", "up()", "turnRight()",
                "turnRight()", "forward()", "forward()", "turnLeft()",
                "forward()", "turnLeft()", "forward()", "down()",
                "forward()", "turnLeft()", "forward()", "down()",
            };
        }
    }
}
