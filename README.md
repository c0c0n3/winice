winice
======
Same as `nice` but for Windows. Same same but different...
This is a simple (or better, simplistic) program that mimics Unix's own
`nice`. Hope it'll keep you entertained.


Wi nice?
--------
Because I couldn't find any easy-peasy way to start a process from Java
with a given [priority class][set-priority]. I first tried my luck with
the obvious:

        cmd /c start /belownormal /wait /b my.exe some args

But the Java `ProcessBuilder` didn't quite like that and gave me endless
trouble with stream redirection. So I started looking for a stinking,
standalone `exe` I could just dump on any recent Windows box and that
depended only on libraries already shipping with Windows, so I could
easily bundle it with a Java app. That ruled out my first candidate, GNU
Core Utils. So I watched the GUI parade coming out of my Google search.
Entertaining, but not exactly what I was hooping for. Then I Googled some
more. And more. After a whole day of scratching around (ya, my Google-foo
must suck!) I came to the conclusion that I might just as well spend the
next day writing it myself, and that's what I did.


Usage
-----
Very similar to `nice` on Unix.

        nice [-n niceness] [COMMAND [ARG]...]

Runs `COMMAND` with a `niceness` value, which affects [process scheduling]
[win-scheduling]. If you specify a `COMMAND` but no `niceness` (i.e. no
`-n` option) then it runs `COMMAND` with a `niceness` value of `10`. With
no `COMMAND` and no `niceness`, it just prints the current `niceness` value
to `stdout`.

Niceness values range from `-20` (most favorable to the process) to `19`
(least favorable to the process) and are converted to Windows [priority
classes][set-priority] as below. (In each range, values are inclusive.)

* `-19` to `-15`: *Real Time*
* `-14` to `-8`: *High*
* `-7` to `-1`: *Above Normal*
* `0` to `6`: *Normal*
* `7` to `13`: *Below Normal*
* `14` to `19`: *Idle*

Any value less than `-20` has the same effect as `-20`. Likewise, any
value greater than `19` has the same effect as `19`. In the reverse
direction, [priority classes][set-priority] map to niceness values
as below.

* *Real Time*: `-19`
* *High*: `-14`
* *Above Normal*: `-7`
* *Normal*: `0`
* *Below Normal*: `7`
* *Idle*: `14`


Installation
------------
On Windows 8 and above, just [grab the latest binary][nice-exe] file and
dump it into some directory. Optionally add the directory to your `PATH`.
For Windows 7 this should work as well, provided you've kept your system
up-to-date. In fact, `winice` needs the .NET framework `4.0` or above
to run. Windows 7 initially didn't ship with .NET, but recent Windows 7
updates include it. If you want to run `winice` on earlier versions of
Windows, you'll need to install .NET `4.0` or any later version.


Bundling with a Java App
------------------------
TODO


Hacking
-------
TODO





[nice-exe]: TODO: point to readme in bin-repo branch
    "winice Binary"
[set-priority]: https://msdn.microsoft.com/en-us/library/windows/desktop/ms686219(v=vs.85).aspx
    "Windows API - SetPriorityClass Function"
[win-scheduling]: https://msdn.microsoft.com/en-us/library/windows/desktop/ms685100(v=vs.85).aspx
    "Windows Scheduling Priorities"
