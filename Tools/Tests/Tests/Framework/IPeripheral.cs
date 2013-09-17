using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LuaInterface;

namespace Tests.Framework
{
    public interface IPeripheral
    {
        string Type { get; }
        LuaTable Instance { get; }
    }
}
