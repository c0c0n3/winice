using System.Diagnostics;

namespace nice
{
    /// <summary>
    /// Parsed command line arguments.
    /// </summary>
    interface IArguments { }

    /// <summary>
    /// Represents an invocation with no arguments.
    /// </summary>
    class NoArguments : IArguments { }

    /// <summary>
    /// Holds the parsed command line arguments for an invocation that 
    /// requested to set the process priority.
    /// </summary>
    class SetPriorityArguments : IArguments
    {
        /// <summary>
        /// Priority to use for the program to run.
        /// </summary>
        public ProcessPriorityClass Priority { get; set; }

        /// <summary>
        /// Path-name of the program to run.
        /// </summary>
        public string ProgramPathName { get; set; }

        /// <summary>
        /// The arguments to pass to the program to run.
        /// </summary>
        /// <remarks>
        /// Arguments are separated by one space and those that contain white
        /// space are quoted.
        /// </remarks>
        public string ProgramArgsLine { get; set; }
    }
}
