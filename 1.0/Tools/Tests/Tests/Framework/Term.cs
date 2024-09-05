using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Tests.Framework
{
    public class Term
    {
        private LuaEnvironment _environment;

        public Term(LuaEnvironment environment)
        {
            _environment = environment;
            environment.CreateTable("term");
            environment.Execute("term.write = function() end");
            environment.Execute("term.clear = function() end");
            environment.Execute("term.clearLine = function() end");
            environment.Execute("term.setCursorPos = function() end");
            environment.Execute("term.getSize = function() return 36, 15; end");
        }
    }
}
