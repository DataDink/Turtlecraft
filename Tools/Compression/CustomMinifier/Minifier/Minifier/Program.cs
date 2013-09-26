using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using Minifier.Lua;

namespace Minifier
{
    class Program
    {
        static void Main(string[] args)
        {
            var path = @"C:\Users\Mark\Documents\GitHub\Turtlecraft\Source\builder.lua";
            var raw = File.ReadAllText(path);
            var parser = new Parser(raw);
            parser.Parse();
        }
    }
}
