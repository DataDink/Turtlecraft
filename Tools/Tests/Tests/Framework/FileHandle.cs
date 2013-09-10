using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using LuaInterface;

namespace Tests.Framework
{
    public class FileHandle
    {
        private readonly LuaEnvironment _environment;
        private StringReader _reader;
        private StringBuilder _writer;
        public TableInfo Table { get; private set; }

        public string Content { get; set; }

        public string Mode { get; set; }


        public FileHandle(LuaEnvironment environment, string content, string mode)
        {
            _environment = environment;
            Content = content;
            Mode = mode.ToLower();
            _reader = new StringReader(Content);
            _writer = mode == "a" ? new StringBuilder(Content) : new StringBuilder(); 
            Table = _environment.CreateTable();
            _environment.RegisterFunction(Table.Path + ".close", this, () => Close());
            _environment.RegisterFunction(Table.Path + ".readLine", this, () => ReadLine());
            _environment.RegisterFunction(Table.Path + ".readAll", this, () => ReadAll());
            _environment.RegisterFunction(Table.Path + ".write", this, () => Write(""));
            _environment.RegisterFunction(Table.Path + ".writeLine", this, () => WriteLine(""));
        }

        public event EventHandler Closed;
        private void Close()
        {
            Content = _writer.ToString();
            Closed(this, null);
        }

        private string ReadLine()
        {
            if (Mode != "r") throw new Exception("File cannot be read in this mode.");
            return _reader.ReadLine();
        }

        private string ReadAll()
        {
            if (Mode != "r") throw new Exception("File cannot be read in this mode.");
            return _reader.ReadToEnd();
        }

        private void Write(string data)
        {
            if (Mode == "r") throw new Exception("File cannot be written to in this mode");
            _writer.Append(data);
        }

        private void WriteLine(string data)
        {
            if (Mode == "r") throw new Exception("File cannot be written to in this mode");
            _writer.AppendLine(data);
        }

    }
}
