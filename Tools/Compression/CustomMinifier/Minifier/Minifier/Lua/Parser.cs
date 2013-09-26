using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace Minifier.Lua
{
    public class Parser
    {
        private static readonly string[] Reserved = new[] {"and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"};
        private static readonly string[] Tokens = new[] {"+", "-", "*", "/", "%", "^", "#", "==", "~=", "<=", ">=", "<", ">", "=", "(", ")", "{", "}", "[", "]", ";", ":", ",", ".", "..", "..."};
        private static readonly string ReferencePattern = @"([A-Za-z_][A-Za-z0-9_]*\s*\.?\s*)+";

        private readonly Parser _parentScope;
        private readonly List<ReferenceValue> _scopeValues = new List<ReferenceValue>();

        public Parser() {}

        private Parser(Parser parent) : this()
        {
            _parentScope = parent;
        }

        private List<ReferenceValue> AllScope()
        {
            var scope = this;
            var combine = new List<ReferenceValue>();
            while (scope != null) {
                combine.AddRange(scope._scopeValues);
                scope = scope._parentScope;
            }
            return combine;
        } 

        private ReferenceValue AddToGlobal(string name)
        {
            var scope = this;
            while (scope._parentScope != null) scope = scope._parentScope;
            var value = scope._scopeValues.FirstOrDefault(v => v.Name == name);
            if (value == null) {
                value = new ReferenceValue(name);
                scope._scopeValues.Add(value);
            }
            return value;
        }

        private ReferenceValue AddToLocal(string name)
        {
            var value = _scopeValues.FirstOrDefault(v => v.Name == name);
            if (value == null) {
                value = new ReferenceValue(name);
                _scopeValues.Add(value);
            }
            return value;
        }

        private string Clean(string lua)
        {
            lua = Regex.Replace(lua, "^function\\s+([^\\(]+)", "$1 = function");
            lua = lua.Trim();
            return lua;
        }

        public List<Statement> Parse(string lua)
        {
            string discard;
            return Parse(lua, out discard);
        } 

        private List<Statement> Parse(string lua, out string remainder)
        {
            var content = Clean(lua);
            var result = new List<Statement>();
            Statement current;
            while ((current = ParseNext(content, out content)) != null) result.Add(current);
            remainder = content;
            return result;
        }

        private Statement ParseNext(string lua, out string remainder)
        {
            lua = lua.TrimStart();
            if (string.IsNullOrWhiteSpace(lua) || lua.StartsWith("end")) return ParseComment(lua, out remainder);
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
            var value = ParseValue(lua, out lua);
            lua = lua.TrimStart();

            var oper = new[] {"or", "and", "<", ">", "<=", ">=", "~=", "==", "..", "+", "-", "*", "/", "%", "^"}
                .FirstOrDefault(lua.StartsWith);
            if (oper != null) {
                lua = lua.Substring(oper.Length).TrimStart();
                return new JoinStatement {
                    Left = value,
                    Operator = oper,
                    Right = ParseStatement(lua, out remainder)
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
            var content = Regex.Match(lua, @"^-?\d+(\.\d+)?").Value;
            remainder = lua.Substring(content.Length);
            return new NumberValue {Content = content};
        }

        private Comment ParseComment(string lua, out string remainder)
        {
            var content = Regex.Match(lua, "^--.*?[\r\n]+").Value;
            remainder = lua.Substring(content.Length);
            return new Comment {Content = content};
        }

        private ReferenceValue ParseReference(string lua, out string remainder)
        {
            var isLocal = lua.StartsWith("local ");
            if (isLocal) lua = lua.Substring("local".Length).TrimStart();
            var referenceName = Regex.Match(lua, "^" + ReferencePattern).Value;
            remainder = lua.Substring(referenceName.Length).TrimStart();
            if (isLocal) return AddToLocal(referenceName);
            return AddToGlobal(referenceName);
        }

        private FunctionValue ParseFunction(string lua, out string remainder)
        {
            var result = new FunctionValue();
            lua = lua.Substring("function".Length).TrimStart();
            var paramStatement = lua.Substring(0, lua.IndexOf(')'));
            if (string.IsNullOrWhiteSpace(paramStatement)) throw new Exception("Function missing param statement");
            var paramItems = Regex.Matches(paramStatement, @"[^\s\(\),]+").OfType<Match>().Select(m => m.Value).ToList();

            var body = new Parser(this);
            paramItems.ForEach(p => body.AddToLocal(p));
            result.Body.Statements.AddRange(body.Parse(lua, out remainder));
            return result;
        }

        private TableValue ParseTable(string lua, out string remainder)
        {
            var result = new TableValue();
            remainder = lua.Substring(1).TrimStart();
            var scope = new Parser(this);
            var index = 1;
            while (!remainder.StartsWith("}")) {
                var key = new ReferenceValue((index++).ToString());
                var statement = scope.ParseNext(remainder, out remainder);
                if (statement is ReferenceValue) {
                    key = (ReferenceValue)statement;
                    statement = scope.ParseNext(remainder, out remainder);
                }
                result.Members.Add(key.Name, statement);
            }
            return result;
        }
    }
}
