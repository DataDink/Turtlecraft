using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Tests.Framework;

namespace Tests
{
    public static class PositionTests
    {
        [Test]
        public static void DefaultPosition(LuaEnvironment environment)
        {
            var coords = environment.Execute("return turtlecraft.position.get();");
            Assert.AreEqual(4, coords.Length);
            Assert.AreEqual(0d, coords[0]);
            Assert.AreEqual(0d, coords[1]);
            Assert.AreEqual(0d, coords[2]);
            Assert.AreEqual(270d, coords[3]);
        }

        [Test]
        public static void RecoverPosition(LuaEnvironment environment)
        {
            var path = environment.Execute("return turtlecraft.directory")[0] as string + "position.data";
            environment.FS.Files.Add(path, "1,1,1,0,0");
            var coords = environment.Execute("return turtlecraft.position.get();");
            var inSync = environment.Execute("return turtlecraft.position.isInSync();");
            Assert.AreEqual(4, coords.Length);
            Assert.AreEqual(1d, coords[0]);
            Assert.AreEqual(1d, coords[1]);
            Assert.AreEqual(1d, coords[2]);
            Assert.AreEqual(0d, coords[3]);
            Assert.AreEqual(true, inSync);
        }
    }
}
