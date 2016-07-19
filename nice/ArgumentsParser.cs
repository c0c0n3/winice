using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Linq;

namespace nice
{
    /// <summary>
    /// An error raised in case of malformed command line arguments.
    /// </summary>
    class ParseException : Exception
    {
        public ParseException(string message) 
            : base(message) { }

        public ParseException(string message, Exception inner) 
            : base(message, inner) { }
    }

    /// <summary>
    /// Turns the command line arguments into an <see cref="IArguments"/> 
    /// instance.
    /// </summary>
    class ArgumentsParser
    {
        static string QuoteIfHasWhitespace(string x)
        {
            x = x ?? string.Empty;
            if (x.Any(Char.IsWhiteSpace))
            {
                x = string.Format("\"{0}\"", x);
            }
            return x;
        }

        IEnumerable<string> args;

        /// <summary>
        /// Creates a new instance to parse the given arguments.
        /// </summary>
        /// <param name="args">The arguments vector as passed in to the 
        /// <c>main</c> method.</param>
        public ArgumentsParser(string[] args)
        {
            this.args = args ?? Enumerable.Empty<string>();
        }

        bool HasMoreArgs
        {
            get { return args.Count() > 0; }
        }

        string NextArg
        {
            get
            {
                var x = args.First();
                args = args.Skip(1);
                return x;
            }
        }

        ProcessPriorityClass ParseNiceness()
        {
            if (!HasMoreArgs)
            {
                throw new ParseException("nice: option requires an argument --'n'");
            }

            var x = NextArg;
            int niceness;
            if (!int.TryParse(x, out niceness))
            {
                throw new ParseException(
                    string.Format("nice: invalid adjustment '{0}'", x));
            }
            return Niceness.FromUnixValue(niceness);
        }

        string ParseProgramPathName()
        {
            if (!HasMoreArgs)
            {
                throw new ParseException("nice: a command must be given with an adjustment");
            }
            return NextArg;
        }

        string ParseProgramArgsLine()
        {
            return args.Select(QuoteIfHasWhitespace)
                       .Aggregate(string.Empty, (x, y) => x + " " + y);  // (*)
        }
        // (*) NB. Quick & dirty.
        // It's inefficient and outputs an extra " " before the first argument.
        // Wish there was a LINQ intersperse...

        SetPriorityArguments ParseCommandLine()
        {
            SetPriorityArguments parsed = new SetPriorityArguments();

            if ("-n".Equals(args.First()))
            {
                var skip = NextArg;
                parsed.Priority = ParseNiceness();
            }
            else
            {
                parsed.Priority = Niceness.DefaultPriority;
            }
            parsed.ProgramPathName = ParseProgramPathName();
            parsed.ProgramArgsLine = ParseProgramArgsLine();

            return parsed;
        }

        /// <summary>
        /// Parses the command line.
        /// </summary>
        /// <returns>Either <see cref="NoArguments"/> or an instance of 
        /// <see cref="SetPriorityArguments"/> representing the parsed command 
        /// line.</returns>
        public IArguments Parse()
        {
            if (!HasMoreArgs)
            {
                return new NoArguments();
            }
            return ParseCommandLine();
        }
    }
    // NOTE. Dunno why I keep thinking parser combinators are a much better way
    // of doing this. I must be insane. I really enjoy writing code that sucks!
}
