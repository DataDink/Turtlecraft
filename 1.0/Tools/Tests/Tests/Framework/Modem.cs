using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LuaInterface;

namespace Tests.Framework
{
    public class Modem : IPeripheral
    {
        public string Type { get { return "modem"; } }
        public LuaTable Instance { get { return null; } }
    }
}
