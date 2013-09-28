using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class IndexValue : Value
    {
        public Statement Indexer { get; set; }
    }
}
