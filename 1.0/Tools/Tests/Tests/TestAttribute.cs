using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Tests
{
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
    public class TestAttribute : Attribute {}
}
