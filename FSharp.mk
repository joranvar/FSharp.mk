# Define the compiler location here
FSC ?= env fsharpc

# Phony targets: ignore files with those names
.PHONY: fsharp

fsharp: $(ASSEMBLIES)

# FSharp assembly template
define FSHARP_template =
 $(1): $(dir $(1))FSharp.Core.dll

 $(1): $$($(1)_sources)
	$$(FSC) -o $$@ $$<
endef

$(foreach assembly,$(ASSEMBLIES),$(eval $(call FSHARP_template,$(assembly))))
