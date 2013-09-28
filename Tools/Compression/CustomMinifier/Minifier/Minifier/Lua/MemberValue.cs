using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class MemberValue : Value
    {
        public string Name { get; private set; }
        public MemberValue(string name)
        {
            Name = name;
        }
    }
}
