# Define the compiler location here
FSC ?= env fsharpc

# Define the location of FSharp.Core.dll here
FSharp.Core.dll ?= /nix/store/9nvx5380w2md40yzr63hbyh22aafsw4j-fsharp-3.1.2.5/lib/mono/4.5/FSharp.Core.dll

# Phony targets: ignore files with those names
.PHONY: fsharp

# Move output assemblies to $(OUTDIR)
fsharp: $(addprefix $(OUTDIR),$(ASSEMBLIES))

# FSharp assembly template
define FSHARP_template =
 $(OUTDIR)$(1): | $(OUTDIR)
 $(OUTDIR)$(1): $$($(1)_sources)
	$$(FSC) -o $$@ $$^
	ln -sf $$(FSharp.Core.dll) $(OUTDIR)
endef

$(foreach assembly,$(ASSEMBLIES),$(eval $(call FSHARP_template,$(assembly))))

# How to make a directory
%/:
	mkdir -p $@
