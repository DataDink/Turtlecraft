using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class JoinStatement : Statement
    {
        public Statement Left { get; set; }
        public string Operator { get; set; }
        public Statement Right { get; set; }
    }
}
