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
        public Peripheral Peripheral { get; private set; }
        public Rednet Rednet { get; private set; }
        public Gps Gps { get; private set; }
        public Term Term { get; private set; }

        public LuaEnvironment(string[] files)
        {
            _files = files;
            Reset();
        }

        public void Reset()
        {
            Api = new Lua();
            RegisterFunction("print", this, () => Print(""));
            RegisterFunction("sleep", this, () => Sleep(0));

            FS = new FileSystem(this);
            Turtle = new Turtle(this);
            Peripheral = new Peripheral(this);
            Rednet = new Rednet(this);
            Gps = new Gps(this);
            Term = new Term(this);
        }

        public event EventHandler OnPrint; 

        private void Print(object text)
        {
            Program.Write((text ?? "").ToString());
            if (OnPrint != null) OnPrint(this, null);
        }

        public event EventHandler OnSleep;

        private void Sleep(double seconds)
        {
            // no, we won't really sleep!
            if (OnSleep != null) OnSleep(this, null);
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

        public LuaFunction RegisterFunction(object target, Expression<Action> methodCall)
        {
            return RegisterFunction("", target, methodCall);
        }

        public LuaFunction RegisterFunction(string path, object target, Expression<Action> methodCall)
        {
            var method = ((MethodCallExpression)methodCall.Body).Method;
            return Api.RegisterFunction(path, target, method);
        }

        public LuaFunction RegisterFunction(TableInfo table, string name, object target, Expression<Action> methodCall)
        {
            var func = RegisterFunction(target, methodCall);
            table.Add(name, func);
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
