using System;
using System.Diagnostics;

namespace nice
{
    /// <summary>
    /// Prints this process's priority class as a niceness value.
    /// </summary>
    /// <seealso cref="Niceness"/>
    class PrintPriority : ITask
    {
        public int Run()
        {
            Process self = Process.GetCurrentProcess();
            int niceness = Niceness.ToUnixValue(self.PriorityClass);
            Console.WriteLine(niceness);

            return ExitCode.Ok;
        }
    }
}
