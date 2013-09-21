using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Tests.Framework;

namespace Tests
{
    public static class FuelTests
    {
        [Test]
        public static void CalculateFuelRemaining(LuaEnvironment environment)
        {
            var fuel = 5;
            environment.Turtle.OnGetFuelLevel += (s, e) => e.Result = fuel;
            environment.Turtle.OnRefuel += (s, e) => {
                fuel += 5;
                e.Result = true;
            };
            environment.Turtle.OnGetItemCount += (s, e) => e.Result = 5;
            environment.Startup();
            environment.Execute("turtlecraft.fuel.require(10);");
            var calc = environment.Execute("return turtlecraft.fuel.estimateRemaining();")[0];

            Assert.AreEqual(35, calc);
        }

    }
}
