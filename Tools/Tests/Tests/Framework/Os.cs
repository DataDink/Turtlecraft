using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Tests.Framework
{
    public class Os
    {
        public Os(LuaEnvironment environment)
        {
            var os = environment.CreateTable("os");
            environment.RegisterFunction(os, "pullEvent", this, () => PullEvent(""));
        }

        private string PullEvent(string evt = null)
        {
            Program.Write(evt, "");
            if (!string.IsNullOrEmpty(evt)) return evt;
            return "timer";
        }
    }
}
