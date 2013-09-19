using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Tests.Framework
{
    public class Gps
    {
        private TableInfo _table;

        public int X { get { return (int)_table.Instance["x"]; } set { _table.Instance["x"] = value; } }
        public int Y { get { return (int)_table.Instance["z"]; } set { _table.Instance["z"] = value; } }
        public int Z { get { return (int)_table.Instance["y"]; } set { _table.Instance["y"] = value; } }

        public Gps(LuaEnvironment environment)
        {
            _table = environment.CreateTable("gps");
            _table.Instance["x"] = 0;
            _table.Instance["y"] = 0;
            _table.Instance["z"] = 0;
            environment.Execute("gps.locate = function() return gps.x, gps.y, gps.z; end"); // not sure how to do this from .net
        }

    }
}
