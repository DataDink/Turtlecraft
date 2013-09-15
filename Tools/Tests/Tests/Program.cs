using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
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
            string[] files;
            using (var dlg = new OpenFileDialog {Title = "Please select Manifest file"}) {
                if (dlg.ShowDialog() != DialogResult.OK) return;
                var path = Path.GetDirectoryName(dlg.FileName);
                files = File.ReadAllLines(dlg.FileName).Select(n => Path.Combine(path, n)).ToArray();
            }

            var assembly = typeof(Program).Assembly;
            var tests = assembly.GetTypes().SelectMany(t => t.GetMethods(BindingFlags.Static | BindingFlags.Public))
                .Where(m => (m.GetCustomAttributes(typeof(TestAttribute), false) ?? new object[0]).Any())
                .ToArray();

            // Test compile first
            using (var environment = new LuaEnvironment()) {
                try {
                    ConfigureEnvironment(environment, files);
                } catch (Exception ex) {
                    Console.WriteLine("Could not load project: {0}", ex.Message);
                    Console.WriteLine("Press any key to quit");
                    Console.ReadKey();
                    return;
                }
            }

            // Run each test (these should all be static methods accepting a lua environment (LuaEnvironment))
            foreach (var test in tests) {
                using (var environment = new LuaEnvironment()) {
                    try {
                        ConfigureEnvironment(environment, files);
                        test.Invoke(null, new object[] { environment });
                        Write("Test Completed: {0}.{1}", test.DeclaringType.Name, test.Name);
                    } catch (Exception ex) {
                        Write("Test Exception: {0}.{1} : {2}", test.DeclaringType.Name, test.Name, ex.Message);
                    }
                }
            }

            using (var dlg = new SaveFileDialog {AddExtension = true, DefaultExt = ".txt", Title = "Save Results", FileName = "test-results.txt", Filter = "Text Files|*.txt"}) {
                if (dlg.ShowDialog() != DialogResult.OK) return;
                File.WriteAllLines(dlg.FileName, Results.ToArray());
            }
        }

        static void ConfigureEnvironment(LuaEnvironment environment, string[] files)
        {
            environment.RegisterFunction("print", null, () => Print(""));
            foreach (var file in files) environment.Api.DoFile(file);
        }

        public static void Print(string text)
        {
            Write(text);
        }

        public static void Write(string format, params object[] args)
        {
            Console.WriteLine(format, args);
            Results.Add(string.Format(format, args));
        }
    }
}
