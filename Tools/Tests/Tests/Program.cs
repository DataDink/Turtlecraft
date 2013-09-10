using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Windows.Forms;
using LuaInterface;

namespace Tests
{
    class Program
    {
        public readonly static List<string> Results = new List<string>(); 

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
            using (var environment = new Lua()) {
                try {
                    foreach (var file in files) environment.LoadFile(file);
                } catch (Exception ex) {
                    Console.WriteLine("Could not load project: {0}", ex.Message);
                    Console.WriteLine("Press any key to quit");
                    Console.ReadKey();
                    return;
                }
            }

            // Run each test (these should all be static methods accepting a lua environment)
            foreach (var test in tests) {
                using (var environment = new Lua()) {
                    try {
                        foreach (var file in files) environment.LoadFile(file);
                        test.Invoke(null, new object[] {environment});
                        Write("Test Completed: {0}.{1}", test.DeclaringType.Name, test.Name);
                    } catch (Exception ex) {
                        Write("Test Exception: {0}.{1} : {2}", test.DeclaringType.Name, test.Name, ex.Message);
                    }
                }
            }

            using (var dlg = new SaveFileDialog {AddExtension = true, DefaultExt = ".txt", Title = "Save Results"}) {
                if (dlg.ShowDialog() != DialogResult.OK) return;
                File.WriteAllLines(dlg.FileName, Results.ToArray());
            }
        }

        public static void Write(string format, params object[] args)
        {
            Console.Write(format, args);
            Results.Add(string.Format(format, args));
        }
    }
}
