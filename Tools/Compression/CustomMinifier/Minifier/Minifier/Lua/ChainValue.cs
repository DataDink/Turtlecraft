using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public abstract class ChainValue : Value
    {
        public Value Owner { get; set; }
        public Value Next { get; set; }
    }
}
