::
:: Simple script to build a release.
:: It runs MSBuild on the nice project file to build the exe and then copies
:: it over to the current directory.
::
:: Assumptions & Dependencies
:: --------------------------
:: * You're running this script from the directory that encloses it.
:: * MSBuild is in your PATH.
:: * You've installed Visual Studio 2015 or later. (The free Community edition
::   will do.)
:: 
:: The easiest thing to do is to open an MSBuild Command Prompt (available 
:: from the Visual Studio Tools in the Start Menu) in this directory to
:: run this script.
:: Note that MSBuild comes with Visual Studio. If you have a standalone MSBuild
:: without Visual Studio, you won't be able to build. In fact, the project file
:: brings in (indirectly) some static analysis rules defined in a rule-set file 
:: that is part of Visual Studio. For the record, on my machine (Windows 7) I 
:: have Visual Studio Community 2015 and the rule-set file is:
::  
::   C:\Program Files\Microsoft Visual Studio 14.0\Team Tools\
::      Static Analysis Tools\\Rule Sets\MinimumRecommendedRules.ruleset
::

msbuild /property:Configuration=Release /target:Clean,Build nice/nice.csproj
copy nice\bin\Release\nice.exe
