# Define the compiler location here
FSC ?= env fsharpc

# Define the location of FSharp.Core.dll here
FSharp.Core.dll ?= /nix/store/9nvx5380w2md40yzr63hbyh22aafsw4j-fsharp-3.1.2.5/lib/mono/4.5/FSharp.Core.dll

# Phony targets: ignore files with those names
.PHONY: fsharp

fsharp: $(ASSEMBLIES)

# FSharp assembly template
define FSHARP_template =
 $(1): $$($(1)_sources)
	$$(FSC) -o $$@ $$<
	ln -s $$(FSharp.Core.dll) $(dir $(1))
endef

$(foreach assembly,$(ASSEMBLIES),$(eval $(call FSHARP_template,$(assembly))))
