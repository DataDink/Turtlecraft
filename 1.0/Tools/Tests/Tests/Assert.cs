using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;

namespace Tests
{
    public static class Assert
    {
        private static void Fail(string message)
        {
            var stack = new StackTrace(2, true).GetFrame(0);
            var line = stack.GetFileLineNumber();
            var col = stack.GetFileColumnNumber();
            var file = Path.GetFileNameWithoutExtension(stack.GetFileName());
            var method = (MethodInfo)stack.GetMethod();
            Program.Write(@"{0}
File: {1}
Position: {2},{3}
Method: {4}", message, file, col, line, method.Name);
        }

        public static void AreEqual(params object[] values)
        {
            values = values ?? new object[0];
            var message = "Values were not equal: " + string.Join(", ", values.Select(v => (v ?? "").ToString()).ToArray());
            if (!values.Any()) return;
            if (values.All(v => v == null)) return;
            var compare = values.First();
            if (compare == null || values.Any(v => !compare.Equals(v))) Fail(message);
        }

        public static void AreNotEqual(params object[] values)
        {
            values = values ?? new object[0];
            var message = "Values were equal: " + string.Join(", ", values.Select(v => (v ?? "").ToString()).ToArray());
            if (!values.Any() || values.All(v => v == null)) Fail(message);
            var compare = values.First(v => v != null);
            if (values.All(compare.Equals)) Fail(message);
        }
    }
}
