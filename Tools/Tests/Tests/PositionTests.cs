using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LuaInterface;
using Tests.Framework;

namespace Tests
{
    public static class PositionTests
    {
        public const string DataFile = "turtlecraft_data/position.data";

        [Test]
        public static void DefaultPosition(LuaEnvironment environment)
        {
            environment.Startup();
            var coords = environment.Execute("return turtlecraft.position.get();");
            Assert.AreEqual(4, coords.Length);
            Assert.AreEqual(0d, coords[0]);
            Assert.AreEqual(0d, coords[1]);
            Assert.AreEqual(0d, coords[2]);
            Assert.AreEqual(270d, coords[3]);
        }

        [Test]
        public static void RecoverBySingleLine(LuaEnvironment environment)
        {
            environment.FS.Files.Add(DataFile, "1,1,1,0,0");
            environment.Startup();

            var coords = environment.Execute("return turtlecraft.position.get();");
            var inSync = environment.Execute("return turtlecraft.position.isInSync();")[0];
            Assert.AreEqual(4, coords.Length);
            Assert.AreEqual(1d, coords[0]);
            Assert.AreEqual(1d, coords[1]);
            Assert.AreEqual(1d, coords[2]);
            Assert.AreEqual(0d, coords[3]);
            Assert.AreEqual(true, inSync);
        }

        [Test]
        public static void RecoverByFuelMarker(LuaEnvironment environment)
        {
            foreach (var fuel in new[] {0, 1, 2}) {
                var f = fuel;
                environment.FS.Files.Add(DataFile, "1,1,1,0,1\r\n2,1,1,0");
                environment.Turtle.OnGetFuelLevel += (s, e) => e.Result = f;
                environment.Startup();

                var shouldSync = fuel != 2;
                var coord = fuel == 1 ? 2d : 1d;

                var coords = environment.Execute("return turtlecraft.position.get();");
                var inSync = environment.Execute("return turtlecraft.position.isInSync();")[0];
                Assert.AreEqual(4, coords.Length);
                Assert.AreEqual(coord, coords[0]);
                Assert.AreEqual(1d, coords[1]);
                Assert.AreEqual(1d, coords[2]);
                Assert.AreEqual(0d, coords[3]);

                Assert.AreEqual(shouldSync, inSync);

                environment.Reset();
            }
        }

        [Test]
        public static void DirectionRecovery(LuaEnvironment environment)
        {
            var tests = new[] {
                "1,1,1,0,0\r\n1,1,1,0",
                "1,1,1,0,0\r\n1,1,1,90"
            };
            var expected = new[] {true, false};

            for (var i = 0; i < tests.Length; i++) {
                var test = tests[i];
                var expectedResult = expected[i];
                environment.FS.Files.Add(DataFile, test);
                environment.Startup();

                var inSync = environment.Execute("return turtlecraft.position.isInSync();")[0];
                Assert.AreEqual(expectedResult, inSync);
                environment.Reset();
            }
        }
    }
}
