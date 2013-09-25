using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using Jurassic;
using LuaInterface;

namespace Minifier
{
    class Program
    {
        static void Main(string[] args)
        {
            var myPath = typeof (Program).Assembly.Location;
            var appDirectory = Path.GetDirectoryName(myPath);
            var projectDirectory = Path.GetFullPath(Path.Combine(appDirectory, "..\\..\\..\\..\\..\\.."));
            var sourceDirectory = Path.GetFullPath(Path.Combine(projectDirectory, "Source"));
            EnsureFileExists("source", sourceDirectory);

            var manifestPath = Path.Combine(sourceDirectory, "manifest");
            EnsureFileExists("manifest", manifestPath);

            var engine = new ScriptEngine();
            engine.ExecuteFile("luaparse.js");
            engine.ExecuteFile("luamin.js");
            engine.Execute("var MINIFY = luamin.minify;"); // hack because I didn't spend time finding the right way to do this in the documentation

            var files = File.ReadAllLines(manifestPath);
            var result = new StringBuilder();
            foreach (var file in files) {
                var filePath = Path.Combine(sourceDirectory, file);
                EnsureFileExists("file", filePath);
                var minified = engine.CallGlobalFunction("MINIFY", File.ReadAllText(filePath)).ToString();
                result.AppendLine("--" + file);
                result.AppendLine(minified);
            }
            EnsureLuaParses(result.ToString());

            var copyIndex = 2;
            var targetDirectory = Path.Combine(projectDirectory, "Compressed");
            var targetName = string.Format("MINIFIED_{0}.lua", DateTime.UtcNow.ToString("yyyy_MM_dd"));
            while (File.Exists(Path.Combine(targetDirectory, targetName))) {
                targetName = string.Format("MINIFIED_{0}_{1}.lua", DateTime.UtcNow.ToString("yyyy_MM_dd"), copyIndex++);
            }
            var targetPath = Path.Combine(targetDirectory, targetName);
            File.WriteAllText(targetPath, result.ToString());
        }

        static void EnsureFileExists(string name, string path)
        {
            if (!Directory.Exists(path) && !File.Exists(path)) {
                Console.Write("Could not locate {0}: {1}", name, path);
                Console.ReadKey();
                Thread.CurrentThread.Abort();
            }
        }

        static void EnsureLuaParses(string lua)
        {
            var environment = new Lua();
            try {
                environment.LoadString(lua, "chunk");
            } catch (Exception ex) {
                Console.WriteLine("Failed to parse");
                Console.WriteLine(ex.Message);
                Console.ReadKey();
                Thread.CurrentThread.Abort();
            }
        }
    }
}
