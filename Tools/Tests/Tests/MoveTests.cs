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
            Assert.AreEqual("turnRight()", environment.Turtle.CallsMade[0]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[1]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[2]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[3]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[4]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[5]);
            Assert.AreEqual("turnLeft()", environment.Turtle.CallsMade[6]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[7]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[8]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[9]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[10]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[11]);
            Assert.AreEqual("up()", environment.Turtle.CallsMade[12]);
            Assert.AreEqual("up()", environment.Turtle.CallsMade[13]);
            Assert.AreEqual("up()", environment.Turtle.CallsMade[14]);
            Assert.AreEqual("up()", environment.Turtle.CallsMade[15]);
            Assert.AreEqual("up()", environment.Turtle.CallsMade[16]);

            environment.Reset();
            environment.Startup();
            Setup(environment);
            environment.Execute("turtlecraft.move.to(-5, -5, -5);");
            Assert.AreEqual("turnLeft()", environment.Turtle.CallsMade[0]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[1]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[2]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[3]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[4]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[5]);
            Assert.AreEqual("turnLeft()", environment.Turtle.CallsMade[6]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[7]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[8]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[9]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[10]);
            Assert.AreEqual("forward()", environment.Turtle.CallsMade[11]);
            Assert.AreEqual("down()", environment.Turtle.CallsMade[12]);
            Assert.AreEqual("down()", environment.Turtle.CallsMade[13]);
            Assert.AreEqual("down()", environment.Turtle.CallsMade[14]);
            Assert.AreEqual("down()", environment.Turtle.CallsMade[15]);
            Assert.AreEqual("down()", environment.Turtle.CallsMade[16]);
        }
    }
}
