# Phony targets: ignore files with those names
.PHONY: all clean fsharp

# Where to look for source files
VPATH = src

# Default target: what to make
all: fsharp

# Output
ASSEMBLIES = HelloWorld.exe HowdyWorld.exe Question.dll TestNuget.exe
OUTDIR = bin/
NUGETDIR = lib/

# Dependencies per assembly
HelloWorld.exe_sources = World.fs Hello.dll FsCheck<lib/net45/FsCheck.dll>
HowdyWorld.exe_sources = World.fs Howdy.dll FsCheck<lib/net45/FsCheck.dll>
Hello.dll_sources = Hello.fs
Howdy.dll_sources = Howdy.fs Question.dll
Question.dll_sources = Question.fs -r:System.Runtime.Serialization.dll
TestNuget.exe_sources = TestNuget.fs FsCheck<lib/net45/FsCheck.dll>

# This provides the fsharp target
include FSharp.mk

clean:
	$(RM) -r $(OUTDIR)
	$(RM) -r $(NUGETDIR)
