using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LuaInterface;

namespace Tests.Framework
{
    public class Peripheral
    {
        private LuaEnvironment _environment;
        public readonly Dictionary<string, IPeripheral> Register = new Dictionary<string, IPeripheral>(); 

        public Peripheral(LuaEnvironment environment)
        {
            _environment = environment;
            _environment.CreateTable("peripheral");
            _environment.RegisterFunction("peripheral.isPresent", this, () => IsPresent(""));
            _environment.RegisterFunction("peripheral.getType", this, () => GetType(""));
            _environment.RegisterFunction("peripheral.getMethods", this, () => GetMethods(""));
            _environment.RegisterFunction("peripheral.call", this, () => Call("", ""));
            _environment.RegisterFunction("peripheral.wrap", this, () => Wrap(""));
            _environment.RegisterFunction("peripheral.getNames", this, () => GetNames());
        }

        private bool IsPresent(string side)
        {
            return Register.ContainsKey(side);
        }

        private string GetType(string side)
        {
            if (!Register.ContainsKey(side)) return null;
            return Register[side].Type;
        }

        private LuaTable GetMethods(string side)
        {
            throw new NotImplementedException("Use wrap, dude");
        }

        private object Call(string side, string method, params object[] parms)
        {
            throw new NotImplementedException("Use wrap, dude");
        }

        private LuaTable Wrap(string side)
        {
            if (!Register.ContainsKey(side)) return null;
            return Register[side].Instance;
        }

        private LuaTable GetNames()
        {
            var table = _environment.CreateTable();
            var names = Register.Keys.ToArray();
            for (var i = 0; i < names.Length; i++) {
                table.Add(names[i]);
            }
            return table.Instance;
        }
    }
}
