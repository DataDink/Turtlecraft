using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class FunctionCall : Value
    {
        public Value Name { get; set; }
        public List<ParenValue> Calls { get; set; }
    }
}
