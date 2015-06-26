using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using LuaInterface;

namespace Minifier
{
    class Program
    {
        static void Main(string[] args)
        {
            var root = Path.GetFullPath("../../../../../../..");
            var sourcePath = Path.Combine(root, "Source");
            var targetPath = Path.Combine(root, "Compressed");
            var deployPath = Path.Combine(root, @"Test\turtlecraft.lua");
            var manifestPath = Path.Combine(sourcePath, "manifest");
            var files = File.ReadAllLines(manifestPath).Select(p => Path.Combine(sourcePath, p)).ToArray();

            var env = new Lua();
            env.DoString(File.ReadAllText("minify.lua"));
            var minifier = env.GetFunction("_G.Minify");
            var result = new StringBuilder();
            foreach (var file in files) {
                var name = Path.GetFileNameWithoutExtension(file);
                result.AppendLine(string.Format("-- File: {0} --", name));
                var minified = minifier.Call(File.ReadAllText(file))[1] as string;
                result.AppendLine(minified);
            }

            var index = 2;
            var rootName = string.Format("MINIFIED_{0}", DateTime.UtcNow.ToString("yyyy_MM_dd"));
            var targetName = string.Format("{0}.lua", rootName);
            while (File.Exists(Path.Combine(targetPath, targetName))) targetName = string.Format("{0}_{1}.lua", rootName, index++);

            File.WriteAllText(Path.Combine(targetPath, targetName), result.ToString());

            if (File.Exists(deployPath)) File.Delete(deployPath);
            File.WriteAllText(deployPath, result.ToString());
        }
    }
}
