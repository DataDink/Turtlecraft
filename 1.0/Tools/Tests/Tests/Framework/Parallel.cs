using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using LuaInterface;

namespace Tests.Framework
{
    public class Parallel
    {
        public Parallel(LuaEnvironment environment)
        {
            var parallel = environment.CreateTable("parallel");
            environment.RegisterFunction(parallel, "waitForAny", this, () => WaitForAny(null, null));
            environment.RegisterFunction(parallel, "waitForAll", this, () => WaitForAll(null, null));
        }

        private List<Thread> CreateThreads(LuaFunction[] functions)
        {
            var threads = new List<Thread>();
            foreach (var func in functions) {
                var threadCall = func;
                var thread = new Thread(() => { try { threadCall.Call(); } catch { } });
                threads.Add(thread);
                thread.Start();
            }
            return threads;
        }

        private void WaitForAny(LuaFunction a, LuaFunction b)
        {
            var threads = CreateThreads(new[]{a, b});

            while (threads.All(t => t.IsAlive)) {
                Thread.Sleep(TimeSpan.FromSeconds(0.25));
            }
            threads.ForEach(t => t.Abort());
        }

        private void WaitForAll(LuaFunction a, LuaFunction b)
        {
            var threads = CreateThreads(new[] { a, b });

            while (threads.Any(t => t.IsAlive)) {
                Thread.Sleep(TimeSpan.FromSeconds(0.25));
            }
        }
    }
}
