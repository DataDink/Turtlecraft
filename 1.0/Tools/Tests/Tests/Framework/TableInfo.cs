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
        public LuaTable Instance { get; private set; }

        public TableInfo(string path, LuaTable table)
        {
            Path = path;
            Instance = table;
        }

        public void Add(object value)
        {
            var index = 1;
            while (Instance.Keys.OfType<int>().Contains(index)) index++;
            Instance[index] = value;
        }

        public void Add(string key, object value)
        {
            Instance[key] = value;
        }
    }
}
