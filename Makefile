# Phony targets: ignore files with those names
.PHONY: all clean fsharp

# Where to look for source files
VPATH = src

# Default target: what to make
all: fsharp

# Output
ASSEMBLIES = HelloWorld.exe HowdyWorld.exe Hello.dll Howdy.dll
OUTDIR = bin/

# Dependencies per assembly
HelloWorld.exe_sources = Hello.fs World.fs
HowdyWorld.exe_sources = Howdy.fs World.fs
Hello.dll_sources = Hello.fs
Howdy.dll_sources = Howdy.fs

# This provides the fsharp target
include FSharp.mk

clean:
	$(RM) -r $(OUTDIR)
