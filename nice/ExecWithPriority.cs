using System;
using System.Diagnostics;

namespace nice
{
    /// <summary>
    /// Creates a new process to run the given command with the specified
    /// niceness.
    /// </summary>
    class ExecWithPriority : ITask
    {
        SetPriorityArguments Args { set; get; }

        public ExecWithPriority(SetPriorityArguments args)
        {
            if (args == null) throw new ArgumentNullException("args");
            Args = args;
        }

        public int Run()
        {
            Process p = new Process();
            p.StartInfo.FileName = Args.ProgramPathName;
            p.StartInfo.Arguments = Args.ProgramArgsLine;
            p.StartInfo.UseShellExecute = false;
                
            p.Start();
            p.PriorityClass = Args.Priority;
            p.WaitForExit();

            return p.ExitCode;
        }
    }
}
