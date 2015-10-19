# Define the executable locations here
FSC ?= env fsharpc
CURL ?= env curl
MONO ?= env mono

# Define the location of FSharp.Core.dll here
FSharp.Core.dll ?= /nix/store/9nvx5380w2md40yzr63hbyh22aafsw4j-fsharp-3.1.2.5/lib/mono/4.5/FSharp.Core.dll

# Phony targets: ignore files with those names
.PHONY: fsharp

# Move output assemblies to $(OUTDIR)
fsharp: $(addprefix $(OUTDIR),$(ASSEMBLIES))

# FSharp executable assembly template
define FSHARP_template =
 ifndef $(1)_has_target
  $(1)_has_target = 1
  $(1)_nuget_refs = $$(filter %.dll>,$$($(1)_sources))
  $(1)_nuget_dlls = $$(addprefix $(OUTDIR),$$(patsubst %>,%,$$(notdir $$($(1)_nuget_refs))))
  $(1)_nuget_pkgs = $$(addprefix $(NUGETDIR),$$(subst <,/,$$(subst >,,$$($(1)_nuget_refs))))

  $$($(1)_nuget_dlls): $$($(1)_nuget_pkgs)
	cp $$^ $(OUTDIR)

  $(OUTDIR)$(1): | $(OUTDIR)
  $(OUTDIR)$(1): | $(OUTDIR)FSharp.Core.dll
  $(OUTDIR)$(1): $$(filter %.fs,$$($(1)_sources))
  $(OUTDIR)$(1): $$($(1)_nuget_dlls)
  $(OUTDIR)$(1): $$(addprefix $(OUTDIR),$$(filter %.dll,$$($(1)_sources)))
	$$(FSC) $(2) -o $$@ $$(filter %.fs,$$^) $$(patsubst %,-r:%,$$(filter %.dll,$$^))
 endif
endef

$(foreach exe,$(filter %.exe,$(ASSEMBLIES)),$(eval $(call FSHARP_template,$(exe))))
$(foreach dll,$(filter %.dll,$(ASSEMBLIES)),$(eval $(call FSHARP_template,$(dll),-a)))
$(foreach dll,$(patsubst %.dll_sources,%.dll,$(filter %.dll_sources,$(.VARIABLES))),$(eval $(call FSHARP_template,$(dll),-a)))

NUGET = $(NUGETDIR)nuget/NuGet.exe

$(NUGET): | $(dir $(NUGET))
	$(CURL) -SsL http://nuget.org/nuget.exe -o $@

# Nuget dependency template
define NUGET_template =
 $(2): | $(NUGET) $(NUGETDIR)
	$(MONO) $(NUGET) install -ExcludeVersion $(1) -OutputDirectory $(NUGETDIR)
endef

all_sources = $(foreach var,$(filter %.dll_sources,$(.VARIABLES)) $(filter %.exe_sources,$(.VARIABLES)),$(value $(var)))
all_nuget_refs = $(filter %.dll>,$(all_sources))
all_nugets = $(firstword $(subst <, ,$(subst >, ,$(all_nuget_refs))))

$(foreach nuget,$(all_nugets),$(eval $(call NUGET_template,$(nuget),$(addprefix $(NUGETDIR),$(subst <,/,$(subst >,,$(filter $(nuget)%,$(all_nuget_refs))))))))

# Link FSharp.Core.dll to where it's needed
%/FSharp.Core.dll:
	ln -sf $(FSharp.Core.dll) $(OUTDIR)

# How to make a directory
%/:
	mkdir -p $@
