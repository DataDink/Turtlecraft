using System;
using System.Linq.Expressions;
using LuaInterface;

namespace Tests.Framework
{
    public class LuaEnvironment : IDisposable
    {
        private readonly string _luaValueStorage = "_annon_" + Guid.NewGuid().ToString().Replace("-", "");

        public Lua Api { get; private set; }
        public FileSystem FS { get; private set; }

        public LuaEnvironment()
        {
            Api = new Lua();
            FS = new FileSystem(this);

            Api.NewTable(_luaValueStorage);
        }

        public TableInfo CreateTable(string path = null)
        {
            var key = path ?? _luaValueStorage + "._" + Guid.NewGuid().ToString().Replace("-", "");

            Api.NewTable(key);
            var info = new TableInfo(key, Api.GetTable(key));
            return info;
        }

        public void RegisterFunction(string path, object target, Expression<Action> methodCall)
        {
            var expr = (MethodCallExpression)methodCall.Body;
            Api.RegisterFunction(path, target, expr.Method);
        }

        public void Dispose()
        {
            Api.Dispose();
        }
    }
}
