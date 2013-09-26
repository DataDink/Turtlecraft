using System.Collections.Generic;

namespace Minifier.Lua
{
    public class Block : Statement
    {
        public virtual bool IsScope { get; set; }
        public virtual string OpenWith { get; set; }
        public virtual string CloseWith { get; set; }
        public readonly List<Statement> Statements = new List<Statement>();
    }
}
