
namespace nice
{
    /// <summary>
    /// A task this program can carry out.
    /// </summary>
    interface ITask
    {
        /// <summary>
        /// Carries out the task.
        /// </summary>
        /// <returns>the exit code.</returns>
        int Run();
    }
}
