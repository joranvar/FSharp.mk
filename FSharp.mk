# Define the compiler location here
FSC ?= env fsharpc

# Define the location of FSharp.Core.dll here
FSharp.Core.dll ?= /nix/store/9nvx5380w2md40yzr63hbyh22aafsw4j-fsharp-3.1.2.5/lib/mono/4.5/FSharp.Core.dll

# Phony targets: ignore files with those names
.PHONY: fsharp

# Move output assemblies to $(OUTDIR)
fsharp: $(addprefix $(OUTDIR),$(ASSEMBLIES))

# FSharp executable assembly template
define FSHARP_template =
 $(OUTDIR)$(1): | $(OUTDIR)
 $(OUTDIR)$(1): | $(OUTDIR)FSharp.Core.dll
 $(OUTDIR)$(1): $$(filter %.fs,$$($(1)_sources))
 $(OUTDIR)$(1): $$(addprefix $(OUTDIR),$$(filter %.dll,$$($(1)_sources)))
	$$(FSC) $(2) -o $$@ $$(filter %.fs,$$^) $$(patsubst %,-r:%,$$(filter %.dll,$$^))
endef

$(foreach exe,$(filter %.exe,$(ASSEMBLIES)),$(eval $(call FSHARP_template,$(exe))))
$(foreach dll,$(filter %.dll,$(ASSEMBLIES)),$(eval $(call FSHARP_template,$(dll),-a)))
$(foreach dll,$(patsubst %.dll_sources,%.dll,$(filter %.dll_sources,$(.VARIABLES))),$(eval $(call FSHARP_template,$(dll),-a)))

# Link FSharp.Core.dll to where it's needed
%/FSharp.Core.dll:
	ln -sf $(FSharp.Core.dll) $(OUTDIR)

# How to make a directory
%/:
	mkdir -p $@
