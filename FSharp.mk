# Define the executable locations here
FSC ?= env fsharpc
CURL ?= env curl
MONO ?= env mono

# Define the location of FSharp.Core.dll here
FSharp.Core.dll ?= /nix/store/9nvx5380w2md40yzr63hbyh22aafsw4j-fsharp-3.1.2.5/lib/mono/4.5/FSharp.Core.dll

# Phony targets: ignore files with those names
.PHONY: fsharp nugetclean

# Move output assemblies to $(OUTDIR)
fsharp: $(addprefix $(OUTDIR),$(join $(addsuffix /,$(basename $(ASSEMBLIES))),$(ASSEMBLIES)))

# Define outdir variables for each assembly, be they intermediate or target
define DEFINE_outdir =
 ifeq ($(filter $(ASSEMBLIES),$(1)),)
  $(1)_outdir = $(OBJDIR)$(basename $(1))/
 else
  $(1)_outdir = $(OUTDIR)$(basename $(1))/
 endif
endef

$(foreach asm,$(patsubst %_sources,%,$(filter %.dll_sources %.exe_sources,$(.VARIABLES))),$(eval $(call DEFINE_outdir,$(asm))))

define COPY_template =
 ifndef $(subst :,_from_,$(1))_has_copy_target
  $(subst :,_from_,$(1))_has_copy_target = 1

  $(1) | $(2)
	cp -u $$(abspath $$^) $$(@D)/
 endif
endef

define COPY_DIR_template =
 ifndef $(subst :,_from_,$(1))_has_copy_dir_target
  $(subst :,_from_,$(1))_has_copy_dir_target = 1

  $(1) | $(2)
	cp -u $$(abspath $$(^D)/*) $$(@D)/
 endif
endef

# FSharp executable assembly template
define FSHARP_template =
 ifndef $(1)_has_target
  $(1)_has_target = 1

  $(1)_nuget_dlls = $$(addprefix :$(NUGETDIR),$$(subst <,/,$$(subst >,,$$(filter %.dll>,$$($(1)_sources)))))
  $(1)_nuget_targets = $$(addprefix $$($(1)_outdir),$$(notdir $$($(1)_nuget_dlls)))
  $$(foreach copy,$$(join $$($(1)_nuget_targets),$$($(1)_nuget_dlls)),$$(eval $$(call COPY_template,$$(copy),$$($(1)_outdir))))

  $(1)_native_dlls = $$(addprefix :,$$(filter %.so,$$($(1)_sources)))
  $(1)_native_targets = $$(addprefix $$($(1)_outdir),$$(notdir $$($(1)_native_dlls)))
  $$(foreach copy,$$(join $$($(1)_native_targets),$$($(1)_native_dlls)),$$(eval $$(call COPY_template,$$(copy),$$($(1)_outdir))))

  $(1)_own_asms = $$(filter-out -r:%,$$(filter %.dll,$$($(1)_sources)))
  $(1)_own_asms_orig_targets = $$(addprefix :,$$(foreach asm,$$($(1)_own_asms),$$($$(asm)_outdir)$$(asm)))
  $(1)_own_asms_targets = $$(addprefix $$($(1)_outdir),$$(notdir $$($(1)_own_asms)))
  $$(foreach copy,$$(join $$($(1)_own_asms_targets),$$($(1)_own_asms_orig_targets)),$$(eval $$(call COPY_DIR_template,$$(copy),$$($(1)_outdir))))

  $$($(1)_outdir)$(1): | $$($(1)_outdir)
  $$($(1)_outdir)$(1): | $$($(1)_outdir)FSharp.Core.dll
  $$($(1)_outdir)$(1): | $$($(1)_native_targets)
  $$($(1)_outdir)$(1): $$(filter %.fs,$$($(1)_sources))
  $$($(1)_outdir)$(1): $$($(1)_nuget_targets)
  $$($(1)_outdir)$(1): $$($(1)_own_asms_targets)
	$$(FSC) -o:$$@\
		$$(filter %.fs,$$^)\
		$$(patsubst %,-r:%,$$(filter %.dll,$$^))\
		$$(filter -r:%.dll,$$($(1)_sources))\
		--nologo $(2)
 endif
endef

$(foreach exe,$(filter %.exe,$(ASSEMBLIES)),$(eval $(call FSHARP_template,$(exe))))
$(foreach dll,$(filter %.dll,$(ASSEMBLIES)),$(eval $(call FSHARP_template,$(dll),-a)))
$(foreach dll,$(patsubst %.dll_sources,%.dll,$(filter %.dll_sources,$(.VARIABLES))),$(eval $(call FSHARP_template,$(dll),-a)))

NUGET = $(TOOLSDIR)nuget/NuGet.exe

$(NUGET): | $(dir $(NUGET))
	$(CURL) -SsL http://nuget.org/nuget.exe -o $@

# Nuget dependency template
define NUGET_template =
 $(sort $(2)): | $(NUGET)
	$(MONO) $(NUGET) install $(1) -ExcludeVersion -OutputDirectory $(NUGETDIR) -Verbosity quiet
endef

all_sources := $(foreach var,$(filter %.dll_sources,$(.VARIABLES)) $(filter %.exe_sources,$(.VARIABLES)),$(call $(var)))
all_nuget_refs := $(filter %.dll>,$(all_sources))
all_nugets := $(sort $(foreach nuget_ref,$(all_nuget_refs),$(firstword $(subst <, ,$(subst >, ,$(nuget_ref))))))

$(foreach nuget,$(all_nugets),$(eval $(call NUGET_template,$(nuget),$(addprefix $(NUGETDIR),$(subst <,/,$(subst >,,$(filter $(nuget)%,$(all_nuget_refs))))))))

# Copy FSharp.Core.dll to where it's needed
%/FSharp.Core.dll:
	cp -u $(abspath $(FSharp.Core.dll)) $(@D)

# How to make a directory
%/:
	mkdir -p $@

nugetclean:
	$(RM) -r $(NUGETDIR)
