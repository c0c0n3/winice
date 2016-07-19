using System;
using System.Diagnostics;

namespace nice
{
    /// <summary>
    /// Converts to and from Unix niceness values.
    /// </summary>
    class Niceness
    {
        /// <summary>
        /// Windows process priorities, ordered from highest to lowest.
        /// </summary>
        static ProcessPriorityClass[] PriorityPoset =
            { ProcessPriorityClass.RealTime
            , ProcessPriorityClass.High
            , ProcessPriorityClass.AboveNormal
            , ProcessPriorityClass.Normal
            , ProcessPriorityClass.BelowNormal
            , ProcessPriorityClass.Idle
            };
        // NB. The conversion formulas below assume (implicitly) we have an 
        // iso F : 6 -> P
        //      [6]   0 -> 1 -> 2 -> 3 -> 4 -> 5
        //      [P]   R -> H -> A -> N -> B -> I
        // The above array encodes this mapping.

        /// <summary>
        /// Default niceness to use when none is specified.
        /// </summary>
        public readonly static ProcessPriorityClass DefaultPriority = FromUnixValue(10);


        static int IndexOf(ProcessPriorityClass p)
        {
            for (int k = 0; k < PriorityPoset.Length; ++k)
            {
                if (PriorityPoset[k].Equals(p))
                {
                    return k;
                }
            }
            throw new ArgumentException("Unknown ProcessPriorityClass value.");  // (*)
        }
        // (*) As long as we keep *all* enum values in PriorityPoset this will
        // never happen...

        /// <summary>
        /// Maps the given Windows process priority class to the corresponding 
        /// Unix niceness value.
        /// </summary>
        /// <param name="windowsValue">the priority class.</param>
        /// <remarks>
        /// The mapping is as follows.
        /// <list type="bullet">
        /// <item><see cref="ProcessPriorityClass.RealTime"/>: <c>-19</c></item>
        /// <item><see cref="ProcessPriorityClass.High"/>: <c>-14</c></item>
        /// <item><see cref="ProcessPriorityClass.AboveNormal"/>: <c>-7</c></item>
        /// <item><see cref="ProcessPriorityClass.Normal"/>: <c>0</c></item>
        /// <item><see cref="ProcessPriorityClass.BelowNormal"/>: <c>7</c></item>
        /// <item><see cref="ProcessPriorityClass.Idle"/>: <c>14</c></item>
        /// </list>
        /// </remarks>
        /// <returns>the niceness value.</returns>
        public static int ToUnixValue(ProcessPriorityClass windowsValue)
        {
            int ix = IndexOf(windowsValue);
            return ix == 0 ? -19 : (-21 + 7 * ix);
        }

        /// <summary>
        /// Converts a Unix niceness value to a Windows priority class.
        /// </summary>
        /// <param name="niceness">The niceness value to map.</param>
        /// <remarks>
        /// Niceness values range from <c>-20</c> (most favorable to the process)
        /// to <c>19</c> (least favorable to the process) and are converted to
        /// priority classes as below. (In each range, values are inclusive.)
        /// <list type="bullet">
        /// <item><c>-19 to -15</c>: <see cref="ProcessPriorityClass.RealTime"/>
        /// </item> 
        /// <item><c>-14 to -8</c>: <see cref="ProcessPriorityClass.High"/>
        /// </item>
        /// <item><c>-7 to -1</c>: <see cref="ProcessPriorityClass.AboveNormal"/>
        /// </item>
        /// <item><c>0 to 6</c>: <see cref="ProcessPriorityClass.Normal"/>
        /// </item>
        /// <item><c>7 to 13</c>: <see cref="ProcessPriorityClass.BelowNormal"/>
        /// </item>
        /// <item><c>14 to 19</c>: <see cref="ProcessPriorityClass.Idle"/>
        /// </item>
        /// </list>
        /// Any value less than <c>-20</c> has the same effect as <c>-20</c>. 
        /// Likewise, any value greater than <c>19</c> has the same effect of 
        /// <c>19</c>.
        /// </remarks>
        /// <returns>The priority class corresponding to the input value.</returns>
        public static ProcessPriorityClass FromUnixValue(int niceness)
        {
            niceness = Math.Max(-19, niceness);
            niceness = Math.Min(20, niceness);

            int q, r;
            q = Math.DivRem(niceness + 21, 7, out r);

            return PriorityPoset[q];
        }
    }
}
