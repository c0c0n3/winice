using System;

namespace nice
{
    /// <summary>
    /// Simple (or better, simplistic) program to mimic Unix's <c>nice</c>.
    /// </summary>
    /// <remarks>
    /// TODO
    /// NB only supports two ways:
    /// 1. nice -n v cmd ...
    /// 2. nice
    /// 
    /// </remarks>
    class Program
    {
        ArgumentsParser Parser { get; set; }

        Program(string[] args)
        {
            Parser = new ArgumentsParser(args);
        }

        ITask LookupTask()
        {
            IArguments a = Parser.Parse();
            if (a is NoArguments)
            {
                return new PrintPriority();
            }
            if (a is SetPriorityArguments)
            {
                return new ExecWithPriority((SetPriorityArguments)a);
            }
            throw new MissingMethodException("no task for: " + a.GetType());
        }

        void Run()
        {
            int status = ExitCode.Ok;
            try
            {
                status = LookupTask().Run();
            } catch (ParseException e) {
                Console.Error.WriteLine(e.Message);
                status = ExitCode.InvalidArgs;
            } catch (Exception e) {
                Console.Error.WriteLine(e);
                status = ExitCode.InternalError;
            }

            Environment.Exit(status);
        }

        static void Main(string[] args)
        {
            new Program(args).Run();
        }
    }

}
