using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class WhileBlock : Block
    {
        public readonly List<Statement> ConditionStatements = new List<Statement>();
    }
}
