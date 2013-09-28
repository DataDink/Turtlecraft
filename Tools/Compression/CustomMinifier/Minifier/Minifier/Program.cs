using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using Minifier.Lua;

namespace Minifier
{
    class Program
    {
        static void Main(string[] args)
        {
            var path = @"..\..\..\..\..\..\..\Source\builder.lua";
            var raw = File.ReadAllText(path);
            var parser = new Parser();
            var result = parser.Parse(raw);
        }
    }
}
