
namespace nice
{
    /// <summary>
    /// Enumerates exit codes.
    /// </summary>
    /// <remarks>
    /// For the lack of better standards, we adopt the Bash recommendations and
    /// use <c>0</c> for success and the range <c>64 - 113</c> for errors. 
    /// (This happens to play well with C/C++ conventions too.)
    /// </remarks>
    class ExitCode
    {
        public const int Ok = 0;
        public const int InvalidArgs = 64;
        public const int InternalError = 65;
    }
}
