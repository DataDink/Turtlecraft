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
        private const string ReferencePattern = @"[A-Za-z_][A-Za-z0-9_]*";

        private readonly Parser _parentScope;
        private readonly List<ReferenceValue> _scopeValues = new List<ReferenceValue>();

        public Parser() {}

        private Parser(Parser parent) : this()
        {
            _parentScope = parent;
        }

        public bool IsGlobal(ReferenceValue value)
        {
            return _scopeValues.Contains(value);
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
            var value = AllScope().FirstOrDefault(v => v.Name == name);
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

        private string Trim(string str)
        {
            return str.TrimStart(" \t\r\n;".ToArray());
        }

        private bool IsKeyword(string lua, string keyword)
        {
            return Regex.IsMatch(lua, string.Format(@"^{0}(?!\S)", keyword));
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
            remainder = Trim(lua);
            if (string.IsNullOrWhiteSpace(remainder) || remainder.StartsWith("end")) return null;
            if (IsKeyword(remainder, "if")) return ParseIf(remainder, out remainder);
            if (IsKeyword(remainder, "else")) return ParseElse(remainder, out remainder);
            if (IsKeyword(remainder, "elseif")) return ParseElseIf(remainder, out remainder);
            if (IsKeyword(remainder, "for")) return ParseFor(remainder, out remainder);
            if (IsKeyword(remainder, "while")) return ParseWhile(remainder, out remainder);
            if (IsKeyword(remainder, "repeat")) return ParseRepeat(remainder, out remainder);
            if (IsKeyword(remainder, "return")) return ParseReturn(remainder, out remainder);
            if (remainder.StartsWith("--")) return ParseComment(remainder, out remainder);
            return ParseStatement(remainder, out remainder);
        }

        private Value ParseValue(string lua, out string remainder)
        {
            lua = Trim(lua);
            if (lua.StartsWith("(")) return ParseParens(lua, out remainder);
            if (lua.StartsWith("{")) return ParseTable(lua, out remainder);
            if (lua.StartsWith("[")) return ParseIndex(lua, out remainder);
            if (lua.StartsWith("\"") || lua.StartsWith("'")) return ParseString(lua, out remainder);
            if (Regex.IsMatch(lua, "^-?\\d")) return ParseNumber(lua, out remainder);
            if (Regex.IsMatch(lua, "^function\\s*\\(")) return ParseFunction(lua, out remainder);
            if (lua.StartsWith("--")) return ParseComment(lua, out remainder);
            return ParseReference(lua, out remainder);
        }

        private Statement ParseStatement(string lua, out string remainder)
        {
            lua = Trim(lua);
            var value = ParseValue(lua, out lua);
            lua = Trim(lua);

            var oper = new[] {"or", "and", "<", ">", "<=", ">=", "~=", "==", "..", "+", "-", "*", "/", "%", "^", "=", ",", "."}
                .FirstOrDefault(lua.StartsWith);
            if (oper != null) {
                lua = Trim(lua.Substring(oper.Length));
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
            lua = lua.Substring(terminator.Length);
            var possibles = Regex.Matches(lua, @"\\*" + terminator).OfType<Match>();
            var match = possibles.FirstOrDefault(m => m.Value.Length % 2 != 0);
            if (match == null) throw new Exception("Unterminated String");

            var content = lua.Substring(0, match.Index + match.Length - terminator.Length);
            remainder = Trim(lua.Substring(content.Length + terminator.Length));
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
            lua += "\r\n";
            var content = Regex.Match(lua, "^--.*?[\r\n]+").Value;
            remainder = lua.Substring(content.Length);
            return new Comment {Content = content};
        }

        private Value ParseCallChain(string lua, out string remainder, Value name)
        {
            remainder = Trim(lua);
            ChainValue result = null;
            if (remainder.StartsWith("(")) {
                result = new FunctionCall {
                    Owner = name,
                    Arguments = (ParenValue)ParseParens(lua, out remainder)
                };
            } else if (remainder.StartsWith(".")) {
                result = new MemberValue {
                    Owner = name,
                };
            }
            var next = Trim(remainder);
            if (new[] {"(", "."}.Any(d => Trim(next).StartsWith(d))) {
                result.Next = ParseCallChain(next, out remainder, result);
            }
            return result;
        } 

        private Value ParseIndex(string lua, out string remainder)
        {
            remainder = Trim(lua.Substring(1));
            var index = new IndexValue {Indexer = ParseStatement(remainder, out remainder)};
            return ParseCallChain(remainder, out remainder, index) ?? index;
        }

        private Value ParseReference(string lua, out string remainder)
        {
            var isLocal = lua.StartsWith("local ");
            remainder = lua;
            if (isLocal) remainder = Trim(remainder.Substring(5));
            var referenceName = Regex.Match(remainder, "^" + ReferencePattern).Value;
            remainder = Trim(remainder.Substring(referenceName.Length));
            var modifier = "";
            if (Reserved.Any(r => r == referenceName)) {
                modifier = referenceName;
                referenceName = Regex.Match(remainder, "^" + ReferencePattern).Value;
                remainder = Trim(remainder.Substring(referenceName.Length));
            };
            var reference = isLocal ? AddToLocal(referenceName) : AddToGlobal(referenceName);
            reference.Modifier = modifier;
            return ParseCallChain(remainder, out remainder, reference) ?? reference;
        }

        private FunctionValue ParseFunction(string lua, out string remainder)
        {
            var result = new FunctionValue();
            lua = Trim(Trim(lua.Substring(8)).Substring(1));
            var paramStatement = lua.Substring(0, lua.IndexOf(')') + 1);
            if (string.IsNullOrWhiteSpace(paramStatement)) throw new Exception("Function missing param statement");
            var paramItems = Regex.Matches(paramStatement, @"[^\s\(\),]+").OfType<Match>().Select(m => m.Value).ToList();
            lua = Trim(lua.Substring(paramStatement.Length));

            var body = new Parser(this);
            paramItems.ForEach(p => body.AddToLocal(p));
            result.Body.Statements.AddRange(body.ParseBlock(lua, out remainder, body, "end"));
            remainder = Trim(remainder.Substring(3));
            return result;
        }

        private TableValue ParseTable(string lua, out string remainder)
        {
            var result = new TableValue();
            remainder = Trim(lua.Substring(1));
            var scope = new Parser(this);
            var index = 1;
            while (!remainder.StartsWith("}")) {
                var key = new ReferenceValue((index++).ToString());
                var statement = scope.ParseNext(remainder, out remainder);
                remainder = Trim(remainder);
                if (remainder.StartsWith("=")) {
                    key = (ReferenceValue)statement;
                    remainder = Trim(remainder.Substring(1));
                    statement = scope.ParseNext(remainder, out remainder);
                }
                result.Members.Add(key.Name, statement);
                remainder = Trim(remainder);
                if (remainder.StartsWith(",")) remainder = Trim(remainder.Substring(1));
            }
            remainder = Trim(remainder.Substring(1));
            return result;
        }

        private Value ParseParens(string lua, out string remainder)
        {
            var result = new ParenValue();
            var empty = Regex.Match(lua, @"^\(\s*\)").Value;
            if (!string.IsNullOrWhiteSpace(empty)) {
                remainder = Trim(lua.Substring(empty.Length));
                return result;
            }

            remainder = lua;
            do {
                remainder = remainder.Substring(1);
                result.Statements.Add(ParseStatement(remainder, out remainder));
                remainder = Trim(remainder);
            } while (!remainder.StartsWith(")"));

            if (!remainder.StartsWith(")")) throw new Exception("Unterminated Parens");
            remainder = Trim(remainder.Substring(1));
            return ParseCallChain(remainder, out remainder, result) ?? result;
        }

        private List<Statement> ParseBlock(string lua, out string remainder, Parser scope, params string[] terminators)
        {
            var result = new List<Statement>();
            scope = scope ?? new Parser(this);
            terminators = terminators.Select(t => string.Format(@"^{0}(?![a-zA-Z0-9_])", t)).ToArray();
            while (!terminators.Any(t => Regex.IsMatch(lua, t))) {
                result.Add(scope.ParseNext(lua, out lua));
                lua = Trim(lua);
            }
            remainder = lua;
            return result;
        }

        private IfBlock ParseIf(string lua, out string remainder)
        {
            lua = Trim(lua.Substring(2));
            var result = new IfBlock();
            result.Condition = ParseStatement(lua, out lua);
            lua = Trim(Trim(lua).Substring("then".Length));

            result.Statements.AddRange(ParseBlock(lua, out lua, null, "end", "else", "elseif"));

            if (lua.StartsWith("end")) lua = Trim(lua.Substring(3));
            remainder = lua;
            return result;
        }

        private ElseIfBlock ParseElseIf(string lua, out string remainder)
        {
            lua = Trim(lua.Substring(6));
            var result = new ElseIfBlock();
            result.Condition = ParseStatement(lua, out lua);
            lua = Trim(Trim(lua).Substring("then".Length));

            result.Statements.AddRange(ParseBlock(lua, out lua, null, "end", "else", "elseif"));

            if (lua.StartsWith("end")) lua = Trim(lua.Substring(3));
            remainder = lua;
            return result;
        }

        private ElseBlock ParseElse(string lua, out string remainder)
        {
            lua = Trim(lua.Substring(4));
            var result = new ElseBlock();
            result.Statements.AddRange(ParseBlock(lua, out lua, null, "end"));

            lua = Trim(lua.Substring(3));
            remainder = lua;
            return result;
        }

        private ForBlock ParseFor(string lua, out string remainder)
        {
            remainder = Trim(lua.Substring(3));
            var result = new ForBlock();
            var declareEnd = Regex.Match(remainder, string.Format(@"(=|\s+in\s+)")).Index;
            var declareStatement = remainder.Substring(0, declareEnd);
            var referenceNames = declareStatement.Split(',').Select(s => s.Trim()).ToArray();
            var scope = new Parser(this);
            result.LoopVariables.AddRange(referenceNames.Select(scope.AddToLocal).ToArray());
            remainder = remainder.Substring(declareEnd);
            result.Join = remainder.StartsWith("=") ? "=" : "in";
            remainder = Trim(remainder.Substring(result.Join.Length));

            result.Condition = ParseStatement(remainder, out remainder);
            remainder = Trim(Trim(remainder).Substring("do".Length));
            result.Statements.AddRange(ParseBlock(remainder, out remainder, scope, "end"));

            remainder = Trim(remainder.Substring(3));
            return result;
        }

        private WhileBlock ParseWhile(string lua, out string remainder)
        {
            remainder = Trim(lua.Substring(5));
            var result = new WhileBlock();
            result.Condition = ParseStatement(remainder, out remainder);
            remainder = Trim(Trim(remainder).Substring("do".Length));
            result.Statements.AddRange(ParseBlock(remainder, out remainder, null, "end"));

            remainder = Trim(remainder.Substring(3));
            return result;
        }

        private RepeatBlock ParseRepeat(string lua, out string remainder)
        {
            remainder = Trim(lua.Substring(6));
            var result = new RepeatBlock();
            result.Statements.AddRange(ParseBlock(remainder, out remainder, null, "until"));
            remainder = Trim(Trim(remainder).Substring(5));

            result.ConditionStatement = ParseStatement(remainder, out remainder);
            remainder = Trim(remainder);

            return result;
        }

        private ReturnStatement ParseReturn(string lua, out string remainder)
        {
            remainder = Trim(lua.Substring(6));
            var result = new ReturnStatement();
            result.Statement = ParseStatement(remainder, out remainder);
            remainder = Trim(remainder);
            return result;
        }
    }
}
