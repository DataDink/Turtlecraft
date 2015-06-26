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

        public EventHandler<LuaResultEventArgs<string>> OnPullEvent;

        private string PullEvent(string evt = null)
        {
            var result = new LuaResultEventArgs<string> {Result = evt ?? "timer"};
            if (OnPullEvent != null) OnPullEvent(this, result);
            return result.Result;
        }
    }
}
