using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LuaInterface;

namespace Tests.Framework
{
    public class Compass : IPeripheral
    {
        public string Type { get { return "compass"; } }
        public LuaTable Instance { get; private set; }

        public Compass(LuaEnvironment environment)
        {
            var table = environment.CreateTable();
            environment.RegisterFunction(table, "getFacing", this, () => GetFacing());
            Instance = table.Instance;
        }

        public event EventHandler<LuaResultEventArgs<int>> OnGetFacing; 

        private int GetFacing()
        {
            var result = new LuaResultEventArgs<int>();
            if (OnGetFacing != null) OnGetFacing(this, result);
            return result.Result;
        }
    }
}
