using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class ReturnStatement : Statement
    {
        public readonly List<Statement> Statements = new List<Statement>();
    }
}
