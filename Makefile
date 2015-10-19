# Phony targets: ignore files with those names
.PHONY: all clean fsharp

# Where to look for source files
VPATH = src

# Default target: what to make
all: fsharp

# Output
ASSEMBLIES = HelloWorld.exe HowdyWorld.exe Question.dll
OUTDIR = bin/

# Dependencies per assembly
HelloWorld.exe_sources = World.fs Hello.dll
HowdyWorld.exe_sources = World.fs Howdy.dll
Hello.dll_sources = Hello.fs
Howdy.dll_sources = Howdy.fs Question.dll
Question.dll_sources = Question.fs

# This provides the fsharp target
include FSharp.mk

clean:
	$(RM) -r $(OUTDIR)
