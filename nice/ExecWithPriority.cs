using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;

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

        private string[] GetExecutableExtensions()
        {
            // Use PATHEXT environment variable like Windows does
            string? pathExt = Environment.GetEnvironmentVariable("PATHEXT");
            if (!string.IsNullOrEmpty(pathExt))
            {
                return pathExt.Split(Path.PathSeparator);
            }

            // Fallback to common Windows executable extensions
            return new string[] { ".com", ".exe", ".bat", ".cmd" };
        }

        private string FindExecutable(string programName)
        {
            // If the file already exists as specified, use it
            if (File.Exists(programName))
            {
                return programName;
            }

            // Build list of directories to search: current directory first, then PATH
            List<string> searchPaths = new List<string>();
            searchPaths.Add(Directory.GetCurrentDirectory());

            string? pathEnv = Environment.GetEnvironmentVariable("PATH");
            if (!string.IsNullOrEmpty(pathEnv))
            {
                searchPaths.AddRange(pathEnv.Split(Path.PathSeparator));
            }

            // Determine what extensions to try
            string currentExtension = Path.GetExtension(programName);
            string[] extensionsToTry = string.IsNullOrEmpty(currentExtension)
                ? GetExecutableExtensions()
                : new string[] { "" }; // Empty string means use the name as-is

            // Search each extension with each path (matches cmd.exe behavior)
            foreach (string ext in extensionsToTry)
            {
                foreach (string searchPath in searchPaths)
                {
                    string fullPath = Path.Combine(searchPath, programName + ext);
                    if (File.Exists(fullPath))
                    {
                        return fullPath;
                    }
                }
            }

            // Not found - return with what was passed as input; an appropriate error
            // will be raised when we try to execute it
            return programName;
        }

        public int Run()
        {
            Process p = new Process();
            p.StartInfo.FileName = FindExecutable(Args.ProgramPathName);
            p.StartInfo.Arguments = Args.ProgramArgsLine;
            p.StartInfo.UseShellExecute = false;

            try
            {
                p.Start();
                p.PriorityClass = Args.Priority;
                p.WaitForExit();

                return p.ExitCode;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("nice: {0}", ex.Message);
                return 1;
            }
        }
    }
}
