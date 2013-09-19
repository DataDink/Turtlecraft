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

        [Test]
        public static void RecoverByCompass(LuaEnvironment environment)
        {
            var compass = new Compass(environment);
            environment.Peripheral.Register.Add("right", compass);

            environment.FS.Files.Add(DataFile, "1,1,1,270,0\r\n1,1,1,0");
            compass.OnGetFacing += (s, e) => e.Result = 0;

            environment.Startup();
            var coords = environment.Execute("return turtlecraft.position.get();");
            var inSync = environment.Execute("return turtlecraft.position.isInSync();")[0];
            Assert.AreEqual(true, inSync);
            Assert.AreEqual(90d, coords[3]);
        }

        [Test]
        public static void RecoverByGps(LuaEnvironment environment)
        {
            // with compass
            environment.Rednet.OnIsOpen += (s, e) => e.Result = true;
            environment.Peripheral.Register.Add("right", new Modem());
            environment.Peripheral.Register.Add("left", new Compass(environment));
            environment.Peripheral.Register.Values.OfType<Compass>().First().OnGetFacing += (s, e) => e.Result = 3; // east
            environment.Gps.X = 1;
            environment.Gps.Y = 2;
            environment.Gps.Z = 3;
            environment.Startup();
            var synced = environment.Execute("return turtlecraft.position.isInSync();")[0];
            var position = environment.Execute("return turtlecraft.position.get();");

            Assert.AreEqual(true, synced);
            Assert.AreEqual(1d, position[0]);
            Assert.AreEqual(2d, position[1]);
            Assert.AreEqual(3d, position[2]);
            Assert.AreEqual(0d, position[3]);
            
            // with movement
            environment.Reset();
            environment.Rednet.OnIsOpen += (s, e) => e.Result = true;
            environment.Peripheral.Register.Add("right", new Modem());
            environment.Gps.X = 0;
            environment.Gps.Y = 0;
            environment.Gps.Z = 0;
            environment.Turtle.OnDetect += (s, e) => e.Result = false;
            environment.Turtle.OnForward += (s, e) => {
                e.Result = true;
                environment.Gps.X = 0;
                environment.Gps.Y = 1; // moves north should calculate to 270
                environment.Gps.Z = 0;
            };
            environment.Startup();
            synced = environment.Execute("return turtlecraft.position.isInSync();")[0];
            position = environment.Execute("return turtlecraft.position.get();");

            Assert.AreEqual(true, synced);
            Assert.AreEqual(0d, position[0]);
            Assert.AreEqual(0d, position[1]);
            Assert.AreEqual(0d, position[2]);
            Assert.AreEqual(270d, position[3]);

            // with only gps
            environment.Reset();
            environment.Rednet.OnIsOpen += (s, e) => e.Result = true;
            environment.Peripheral.Register.Add("right", new Modem());
            environment.Gps.X = 0;
            environment.Gps.Y = 0;
            environment.Gps.Z = 0;
            environment.Turtle.OnDetect += (s, e) => e.Result = true;
            environment.Startup();
            synced = environment.Execute("return turtlecraft.position.isInSync();")[0];
            position = environment.Execute("return turtlecraft.position.get();");

            Assert.AreEqual(false, synced);
            Assert.AreEqual(0d, position[0]);
            Assert.AreEqual(0d, position[1]);
            Assert.AreEqual(0d, position[2]);
            Assert.AreEqual(270d, position[3]);
        }

        [Test]
        public static void CachePosition(LuaEnvironment environment)
        {
            environment.Turtle.OnGetFuelLevel += (s, e) => e.Result = 5;
            environment.Startup();
            var nonmoving = environment.Execute("return turtlecraft.position.set(1, 2, 3, 4)")[0];
            Assert.AreEqual(false, nonmoving);
            Assert.AreEqual(1, environment.FS.Files.Count);
            Assert.AreEqual("1,2,3,4,5\r\n0,0,0,270\r\n", environment.FS.Files[DataFile]);

            environment.Reset();
            environment.Turtle.OnGetFuelLevel += (s, e) => e.Result = 5;
            environment.Startup();
            var moving = environment.Execute("return turtlecraft.position.set(1, 2, 3, 4, function() return true; end)")[0];
            Assert.AreEqual(true, moving);
            Assert.AreEqual(1, environment.FS.Files.Count);
            Assert.AreEqual("1,2,3,4,5\r\n", environment.FS.Files[DataFile]);
        }
    }
}
