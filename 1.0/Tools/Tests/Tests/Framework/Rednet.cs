using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Tests.Framework
{
    public class Rednet
    {
        public Rednet(LuaEnvironment environment)
        {
            var table = environment.CreateTable("rednet");
            environment.RegisterFunction("rednet.open", this, () => Open(""));
            environment.RegisterFunction("rednet.close", this, () => Close(""));
            environment.RegisterFunction("rednet.isOpen", this, () => IsOpen(""));

            // Ignoring announce, send, broadcast and receive
        }

        private void Open(string side) {}

        private void Close(string side) {}

        public event EventHandler<LuaResultEventArgs<bool>> OnIsOpen; 

        private bool IsOpen(string side)
        {
            var result = new LuaResultEventArgs<bool>();
            if (OnIsOpen != null) OnIsOpen(this, result);
            return result.Result;
        }
    }
}
