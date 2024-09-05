using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Tests.Framework
{
    public class LuaResultEventArgs<TResult> : EventArgs
    {
        public TResult Result { get; set; }
    }
}
