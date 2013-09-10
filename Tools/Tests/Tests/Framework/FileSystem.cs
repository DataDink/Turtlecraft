using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using LuaInterface;

namespace Tests.Framework
{
    public class FileSystem
    {
        private LuaEnvironment _environment;
        private readonly List<FileHandle> _openHandles = new List<FileHandle>(); 
        public readonly Dictionary<string, string> Files = new Dictionary<string, string>(StringComparer.InvariantCultureIgnoreCase);

        public FileSystem(LuaEnvironment environment)
        {
            _environment = environment;
            _environment.CreateTable("fs");
            _environment.RegisterFunction("fs.list", this, () => List(""));
            _environment.RegisterFunction("fs.exists", this, () => Exists(""));
            _environment.RegisterFunction("fs.isDir", this, () => IsDir(""));
            _environment.RegisterFunction("fs.isReadOnly", this, () => IsReadOnly(""));
            _environment.RegisterFunction("fs.getName", this, () => GetName(""));
            _environment.RegisterFunction("fs.getDrive", this, () => GetDrive(""));
            _environment.RegisterFunction("fs.getSize", this, () => GetSize(""));
            _environment.RegisterFunction("fs.getFreeSpace", this, () => GetFreeSpace(""));
            _environment.RegisterFunction("fs.makeDir", this, () => MakeDir(""));
            _environment.RegisterFunction("fs.move", this, () => Move("", ""));
            _environment.RegisterFunction("fs.copy", this, () => Copy("", ""));
            _environment.RegisterFunction("fs.delete", this, () => Delete(""));
            _environment.RegisterFunction("fs.combine", this, () => Combine("", ""));
            _environment.RegisterFunction("fs.open", this, () => Open("", ""));
        }

        private string CleanPath(string path)
        {
            if (path == null) path = "";
            path = path.Trim();
            return path;
        }

        private string CleanDirectory(string path)
        {
            path = CleanPath(path);
            if (!path.EndsWith("/")) path = path + "/";
            return path;
        }

        private LuaTable List(string path)
        {
            path = CleanDirectory(path);
            var paths = string.IsNullOrEmpty(path)
                ? Files.Keys.ToArray()
                : Files.Keys.Where(k => k.StartsWith(path, StringComparison.InvariantCultureIgnoreCase)).ToArray();
            var table = _environment.CreateTable();
            for (var i = 1; i <= paths.Length; i++) {
                table.Table[i] = paths[i - 1];
            }
            return table.Table;
        }

        private bool Exists(string path)
        {
            path = path.Trim();
            return Files.ContainsKey(path);
        }

        private bool IsDir(string path)
        {
            path = CleanDirectory(path);
            return !Files.ContainsKey(path) && Files.Keys.Any(k => k.StartsWith(path, StringComparison.InvariantCultureIgnoreCase));
        }

        private bool IsReadOnly(string path)
        {
            return false;
        }

        private string GetName(string path)
        {
            path = CleanPath(path);
            return path.Split("/".ToArray()).LastOrDefault();
        }

        private string GetDrive(string path)
        {
            throw new NotImplementedException();
        }

        private int GetSize(string path)
        {
            throw new NotImplementedException();
        }

        private int GetFreeSpace(string path)
        {
            throw new NotImplementedException();
        }

        private void MakeDir(string path)
        {
            
        }

        private void Move(string from, string to)
        {
            
        }

        private void Copy(string from, string to)
        {
            
        }

        private void Delete(string path)
        {
            path = CleanPath(path);
            Files.Remove(path);
        }

        private string Combine(string basePath, string localPath)
        {
            return basePath + "/" + localPath;
        }

        private LuaTable Open(string path, string mode)
        {
            path = CleanPath(path);
            if (!Files.ContainsKey(path) && mode == "w") Files.Add(path, "");
            if (!Files.ContainsKey(path)) return null;
            var data = Files[path];

            var handle = new FileHandle(_environment, data, mode);
            _openHandles.Add(handle);
            handle.Closed += (s, e) => {
                _openHandles.Remove(handle);
                Files[path] = handle.Content;
            };
            return handle.Table.Table;
        }
    }
}
