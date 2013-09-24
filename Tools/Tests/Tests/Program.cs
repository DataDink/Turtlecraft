using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using LuaInterface;
using Tests.Framework;

namespace Tests
{
    class Program
    {
        public readonly static List<string> Results = new List<string>();
        public static readonly List<string> ProjectFiles = new List<string>();


        [STAThread]
        static void Main(string[] args)
        {
            var myPath = typeof(Program).Assembly.Location;
            var appDirectory = Path.GetDirectoryName(myPath);
            var projectDirectory = Path.GetFullPath(Path.Combine(appDirectory, "..\\..\\..\\..\\.."));
            var sourceDirectory = Path.GetFullPath(Path.Combine(projectDirectory, "Source"));
            EnsureFileExists("source", sourceDirectory);

            var manifestPath = Path.Combine(sourceDirectory, "manifest");
            EnsureFileExists("manifest", manifestPath);

            var files = File.ReadAllLines(manifestPath)
                .Select(f => Path.Combine(sourceDirectory, f))
                .ToArray();

            var assembly = typeof(Program).Assembly;
            var tests = assembly.GetTypes().SelectMany(t => t.GetMethods(BindingFlags.Static | BindingFlags.Public))
                .Where(m => (m.GetCustomAttributes(typeof(TestAttribute), false) ?? new object[0]).Any())
                .ToArray();

            // Test compile first
            try {
                new LuaEnvironment(files);
            } catch (Exception ex) {
                Console.WriteLine("Could not load project: {0}", ex.Message);
                Console.WriteLine("Press any key to quit");
                Console.ReadKey();
                return;
            }

            // Run each test (these should all be static methods accepting a lua environment (LuaEnvironment))
            foreach (var test in tests) {
                using (var environment = new LuaEnvironment(files)) {
                    try {
                        test.Invoke(null, new object[] { environment });
                        Write("Test Completed: {0}.{1}", test.DeclaringType.Name, test.Name);
                    } catch (Exception ex) {
                        var inner = ex;
                        while (inner.InnerException != null) inner = inner.InnerException;
                        Write("Test Exception: {0}.{1} : {2}", test.DeclaringType.Name, test.Name, inner.Message);
                    }
                    Write("----");
                }
            }

            using (var dlg = new SaveFileDialog {AddExtension = true, DefaultExt = ".txt", Title = "Save Results", FileName = "test-results.txt", Filter = "Text Files|*.txt"}) {
                if (dlg.ShowDialog() != DialogResult.OK) return;
                File.WriteAllLines(dlg.FileName, Results.ToArray());
            }
        }

        static void EnsureFileExists(string name, string path)
        {
            if (!Directory.Exists(path) && !File.Exists(path)) {
                Console.Write("Could not locate {0}: {1}", name, path);
                Console.ReadKey();
                Thread.CurrentThread.Abort();
            }
        }

        public static void Write(string format, params object[] args)
        {
            Console.WriteLine(format, args);
            Results.Add(string.Format(format, args));
        }
    }
}
