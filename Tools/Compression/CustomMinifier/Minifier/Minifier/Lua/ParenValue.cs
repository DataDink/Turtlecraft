﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class ParenValue : Value
    {
        public readonly List<Statement> Statements = new List<Statement>();
    }
}
