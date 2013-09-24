using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using Jurassic;

namespace Minifier
{
    class Program
    {
        static void Main(string[] args)
        {
            var myPath = typeof (Program).Assembly.Location;
            var solutionPath = Path.GetDirectoryName(myPath);
            var projectPath = Path.GetFullPath(Path.Combine(solutionPath, "..\\..\\..\\..\\..\\..\\Source"));
            EnsureFileExists("source", projectPath);

            var manifestPath = Path.Combine(projectPath, "manifest");
            EnsureFileExists("manifest", manifestPath);

            var files = File.ReadAllLines(manifestPath);
            var raw = new StringBuilder();
            foreach (var file in files) {
                var filePath = Path.Combine(projectPath, file);
                EnsureFileExists("file", filePath);
                raw.AppendLine(File.ReadAllText(filePath));
            }

            var engine = new ScriptEngine();
            engine.ExecuteFile("luaparse.js");
            engine.ExecuteFile("luamin.js");
            engine.Execute("var MINIFY = luamin.minify;"); // hack because I didn't spend time finding the right way to do this in the documentation
            var result = engine.CallGlobalFunction("MINIFY", raw.ToString());

            var copyIndex = 2;
            var targetPath = Path.Combine(projectPath, "Compressed");
            var targetName = string.Format("MINIFIED_{0}.lua", DateTime.UtcNow.ToString("yyyy_MM_dd"));
            while (File.Exists(Path.Combine(targetPath, targetName))) targetName = string.J
        }

        static void EnsureFileExists(string name, string path)
        {
            if (!Directory.Exists(path) && !File.Exists(path)) {
                Console.Write("Could not locate {0}: {1}", name, path);
                Console.ReadKey();
                Thread.CurrentThread.Abort();
            }
        }
    }
}
