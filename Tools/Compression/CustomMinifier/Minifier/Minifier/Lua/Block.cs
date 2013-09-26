using System.Collections.Generic;

namespace Minifier.Lua
{
    public class Block : Statement
    {
        public readonly List<Statement> Statements = new List<Statement>();
    }
}
