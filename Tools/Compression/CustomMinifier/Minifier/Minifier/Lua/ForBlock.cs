using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class ForBlock : Block
    {
        public readonly List<ReferenceValue> LoopVariables = new List<ReferenceValue>();
        public string Join { get; set; }
        public readonly List<Statement> ConditionStatements = new List<Statement>();
    }
}
