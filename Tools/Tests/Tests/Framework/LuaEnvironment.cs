using System;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using LuaInterface;

namespace Tests.Framework
{
    public class LuaEnvironment : IDisposable
    {
        private readonly string[] _files;

        public Lua Api { get; private set; }
        public FileSystem FS { get; private set; }
        public Turtle Turtle { get; private set; }

        public LuaEnvironment(string[] files)
        {
            _files = files;
            Reset();
        }

        public void Reset()
        {
            Api = new Lua();
            RegisterFunction("print", null, () => Program.Print(""));
            FS = new FileSystem(this);
            Turtle = new Turtle(this);
        }

        public void Startup()
        {
            foreach (var file in _files) {
                Api.DoFile(file);
            }
        }

        public TableInfo CreateTable(string path)
        {
            Api.NewTable(path);
            return new TableInfo(path, Api.GetTable(path));
        }

        public TableInfo CreateTable()
        {
            var table = Api.DoString("return {};");
            return new TableInfo("", table.FirstOrDefault() as LuaTable);
        }

        public LuaFunction RegisterFunction(string path, object target, Expression<Action> methodCall)
        {
            var method = ((MethodCallExpression)methodCall.Body).Method;
            return Api.RegisterFunction(path, target, method);
        }

        public LuaFunction RegisterFunction(TableInfo table, string name, object target, Expression<Action> methodCall)
        {
            var method = ((MethodCallExpression)methodCall.Body).Method;
            var func = Api.RegisterFunction("", target, method);
            table.Table[name] = func;
            return func;
        }

        public object[] Execute(string lua)
        {
            return Api.DoString(lua);
        }

        public void Dispose()
        {
            Api.Dispose();
        }
    }
}
