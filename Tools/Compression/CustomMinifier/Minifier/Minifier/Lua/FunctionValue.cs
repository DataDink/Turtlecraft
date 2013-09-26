using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class FunctionValue : Value
    {
        public readonly List<ReferenceValue> Parameters = new List<ReferenceValue>();
        public readonly Block Body = new Block();
    }
}
