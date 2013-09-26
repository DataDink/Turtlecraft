using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class TableValue : Value
    {
        public readonly Dictionary<string, Statement> Members = new Dictionary<string, Statement>();
    }
}
