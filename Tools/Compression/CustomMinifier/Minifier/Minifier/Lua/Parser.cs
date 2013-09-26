using System;
using System.Linq;
using System.Text.RegularExpressions;

namespace Minifier.Lua
{
    public class Parser
    {
        private static readonly string[] Reserved = new[] {"and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"};
        private static readonly string[] Tokens = new[] {"+", "-", "*", "/", "%", "^", "#", "==", "~=", "<=", ">=", "<", ">", "=", "(", ")", "{", "}", "[", "]", ";", ":", ",", ".", "..", "..."};
        private static readonly string ValidCharacters = "[A-Za-z_]";

        private string _raw;

        public Parser(string lua)
        {
            _raw = lua;
        }

        public Block Parse()
        {
            var content = _raw;
            var result = new Block();
            while (true) {
                if (string.IsNullOrWhiteSpace(content)) return result;
                var statement = ParseNext(content, out content);
                result.Statements.Add(statement);
            }
        }

        private Statement ParseNext(string lua, out string remainder)
        {
            lua = lua.TrimStart();
            if (lua.StartsWith("if")) return ParseIf(lua, out remainder);
            if (lua.StartsWith("else")) return ParseElse(lua, out remainder);
            if (lua.StartsWith("elseif")) return ParseElseIf(lua, out remainder);
            if (lua.StartsWith("for")) return ParseFor(lua, out remainder);
            if (lua.StartsWith("while")) return ParseWhile(lua, out remainder);
            if (lua.StartsWith("repeat")) return ParseRepeat(lua, out remainder);
            if (lua.StartsWith("return")) return ParseReturn(lua, out remainder);
            if (lua.StartsWith("--")) return ParseComment(lua, out remainder);
            return ParseStatement(lua, out remainder);
        }

        private Value ParseValue(string lua, out string remainder)
        {
            lua = lua.TrimStart();
            if (lua.StartsWith("(")) return ParseParens(lua, out remainder);
            if (lua.StartsWith("{")) return ParseTable(lua, out remainder);
            if (lua.StartsWith("\"") || lua.StartsWith("'")) return ParseString(lua, out remainder);
            if (Regex.IsMatch(lua, "^-?\\d")) return ParseNumber(lua, out remainder);
            if (Regex.IsMatch(lua, "^function\\s*\\(")) return ParseFunction(lua, out remainder);
            if (lua.StartsWith("--")) return ParseComment(lua, out remainder);
            return ParseReference(lua, out remainder);
        }

        private Statement ParseStatement(string lua, out string remainder)
        {
            lua = lua.TrimStart();
            var isLocal = lua.StartsWith("local ");
            if (isLocal) lua = lua.Substring(5).TrimStart();

            if (Regex.IsMatch(lua, "^function\\s*[^\\(]")) {
                lua = lua.Substring(8).TrimStart();
                lua = Regex.Replace(lua, "^function\\s*([^\\(]+)", "$1 = function").TrimStart();
            }
            var value = ParseValue(lua, out lua);
            lua = lua.TrimStart();
            value.IsLocal = isLocal;

            var oper = new[] {"or", "and", "<", ">", "<=", ">=", "~=", "==", "..", "+", "-", "*", "/", "%", "^"}
                .FirstOrDefault(lua.StartsWith);
            if (oper != null) {
                lua = lua.Substring(oper.Length).TrimStart();
                return new JoinStatement {
                    Left = value,
                    Operator = oper,
                    Right = ParseValue(lua, out remainder)
                };
            }
            remainder = lua;
            return value;
        }

        private StringValue ParseString(string lua, out string remainder)
        {
            var terminator = lua[0].ToString();
            var possibles = Regex.Matches(lua, @"\\*" + terminator).OfType<Match>();
            var match = possibles.FirstOrDefault(m => m.Value.Length % 2 != 0);
            if (match == null) throw new Exception("Unterminated String");

            var content = lua.Substring(0, match.Index + match.Length);
            remainder = lua.Substring(content.Length);
            return new StringValue { Content = content };
        }

        private NumberValue ParseNumber(string lua, out string remainder)
        {
            
        }
    }
}
