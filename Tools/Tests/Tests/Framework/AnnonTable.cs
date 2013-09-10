using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LuaInterface;

namespace Tests.Framework
{
    public class TableInfo
    {
        public string Path { get; private set; }
        public LuaTable Table { get; private set; }

        public TableInfo(string path, LuaTable table)
        {
            Path = path;
            Table = table;
        }
    }
}
