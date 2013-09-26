using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class ReferenceValue : Value
    {
        public string Name { get; set; }
        public string OriginalName { get; private set; }

        public ReferenceValue(string name)
        {
            Name = name;
            OriginalName = name;
        }
    }
}
