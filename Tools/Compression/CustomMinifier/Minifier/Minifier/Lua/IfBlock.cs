﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Minifier.Lua
{
    public class IfBlock : Block
    {
        public Statement Condition { get; set; }
    }
}
