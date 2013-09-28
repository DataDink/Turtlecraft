using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class ReservedValue : Value
    {
        public string Name { get; private set; }
        public ReservedValue(string name)
        {
            Name = name;
        }
    }
}
