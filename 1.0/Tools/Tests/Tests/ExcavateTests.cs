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
            environment.Execute("turtlecraft.fuel.estimateRemaining = function() return turtle.getFuelLevel(); end");
            environment.Turtle.OnGetFuelLevel += (s, e) => e.Result = 999999;
            environment.FS.Files.Clear();
        }

        [Test]
        public static void MovementTest(LuaEnvironment environment)
        {
            environment.Startup();
            environment.Os.OnPullEvent += (s, e) => { while (true) {} };
            Setup(environment);
            environment.Execute("turtlecraft.excavate.debug.start(1, 1, 1, 3, 3);");
            var careAbout = new[] {
                "forward()", "up()", "down()", "turnLeft()", "turnRight()"
            };
            var moves = string.Join(",", environment.Turtle.CallsMade
                .Where(careAbout.Contains)
                .Select(m => m.Replace("()", ""))
                .ToArray());
            var getToStartingPoint = "turnLeft,forward,up,up";
            var excavateTopLayer = "turnRight,turnRight,forward,forward,turnLeft,forward,turnLeft,forward,forward";
            var excavateMidLayer = "down,down,down,turnRight,turnRight,forward,forward,turnRight,forward,turnRight,forward,forward";
            var excavateBotLayer = "down,turnRight,turnRight,forward,forward,turnLeft,forward,turnLeft,forward,forward";
            var returnHome = "turnRight,turnRight,forward,turnRight,forward,up,up";
            var faceForward = "turnRight,turnRight";
            var expected = string.Join(",", new[] { getToStartingPoint, excavateTopLayer, excavateMidLayer, excavateBotLayer, returnHome, faceForward });
            Assert.AreEqual(expected, moves);
        }
    }
}
