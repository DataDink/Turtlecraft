using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Tests.Framework;

namespace Tests
{
    public static class MoveTests
    {
        private static void Setup(LuaEnvironment environment)
        {
            environment.Execute("test = {x = 0, y = 0, z = 0, d = 270};");
            environment.Execute("turtlecraft.position.get = function() return test.x, test.y, test.z, test.d; end");
            environment.Execute("turtlecraft.position.set = function(x, y, z, d, action) test.x = x; test.y = y; test.z = z; test.d = d; return action(); end");
            environment.Turtle.OnGetFuelLevel += (s, e) => e.Result = 99999;
        }

        [Test]
        public static void FacingMovements(LuaEnvironment environment)
        {
            environment.Startup();
            Setup(environment);
            environment.Execute("turtlecraft.move.face(270)");
            Assert.AreEqual(0, environment.Turtle.CallsMade.Count);

            environment.Reset();
            environment.Startup();
            Setup(environment);
            environment.Execute("turtlecraft.move.face(0)");
            Assert.AreEqual(1, environment.Turtle.CallsMade.Count);
            Assert.AreEqual("turnRight()", environment.Turtle.CallsMade[0]);

            environment.Reset();
            environment.Startup();
            Setup(environment);
            environment.Execute("turtlecraft.move.face(180)");
            Assert.AreEqual(1, environment.Turtle.CallsMade.Count);
            Assert.AreEqual("turnLeft()", environment.Turtle.CallsMade[0]);

            environment.Reset();
            environment.Startup();
            Setup(environment);
            environment.Execute("turtlecraft.move.face(90)");
            Assert.AreEqual(2, environment.Turtle.CallsMade.Count);
            Assert.AreEqual("turnRight()", environment.Turtle.CallsMade[0]);
            Assert.AreEqual("turnRight()", environment.Turtle.CallsMade[1]);
        }

        [Test]
        public static void PositionMovements(LuaEnvironment environment)
        {
            // order expected is to move x, y, then z
            environment.Startup();
            Setup(environment);
            environment.Execute("turtlecraft.move.to(5, 5, 5);");
            var moves = environment.Turtle.CallsMade.Where(c => !c.Contains("getFuelLevel")).ToArray();
            Assert.AreEqual("turnRight()", moves[0]);
            Assert.AreEqual("forward()", moves[1]);
            Assert.AreEqual("forward()", moves[2]);
            Assert.AreEqual("forward()", moves[3]);
            Assert.AreEqual("forward()", moves[4]);
            Assert.AreEqual("forward()", moves[5]);
            Assert.AreEqual("turnLeft()", moves[6]);
            Assert.AreEqual("forward()", moves[7]);
            Assert.AreEqual("forward()", moves[8]);
            Assert.AreEqual("forward()", moves[9]);
            Assert.AreEqual("forward()", moves[10]);
            Assert.AreEqual("forward()", moves[11]);
            Assert.AreEqual("up()", moves[12]);
            Assert.AreEqual("up()", moves[13]);
            Assert.AreEqual("up()", moves[14]);
            Assert.AreEqual("up()", moves[15]);
            Assert.AreEqual("up()", moves[16]);

            environment.Reset();
            environment.Startup();
            Setup(environment);
            environment.Execute("turtlecraft.move.to(-5, -5, -5);");
            moves = environment.Turtle.CallsMade.Where(c => !c.Contains("getFuelLevel")).ToArray();
            Assert.AreEqual("turnLeft()", moves[0]);
            Assert.AreEqual("forward()", moves[1]);
            Assert.AreEqual("forward()", moves[2]);
            Assert.AreEqual("forward()", moves[3]);
            Assert.AreEqual("forward()", moves[4]);
            Assert.AreEqual("forward()", moves[5]);
            Assert.AreEqual("turnLeft()", moves[6]);
            Assert.AreEqual("forward()", moves[7]);
            Assert.AreEqual("forward()", moves[8]);
            Assert.AreEqual("forward()", moves[9]);
            Assert.AreEqual("forward()", moves[10]);
            Assert.AreEqual("forward()", moves[11]);
            Assert.AreEqual("down()", moves[12]);
            Assert.AreEqual("down()", moves[13]);
            Assert.AreEqual("down()", moves[14]);
            Assert.AreEqual("down()", moves[15]);
            Assert.AreEqual("down()", moves[16]);
        }
    }
}
