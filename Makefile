# this makefile is for deploying multiple projects across multiple clients' websites.
# it requires ssh public-key authentication on the ssh remote hosts.
# add new websites in generate-make-targets.py


SHELL := /bin/sh
SSH := /usr/bin/ssh
REMOTE_GIT := git
REMOTE_GIT_ARG := -C
ECHO := /bin/echo
RSYNC := /usr/bin/rsync
WP := /usr/local/bin/wp
WP_COMMAND := update
GREP := /usr/bin/grep
AWK := /usr/bin/awk
SORT := /usr/bin/sort
GIT_COMMAND := pull
GIT_REMOTE := origin
GIT_BRANCH := production
# https://stackoverflow.com/questions/2004760/get-makefile-directory
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
EXCLUDE := ${MAKEFILE_DIR}excluded.txt
GENERATE_MAKE_TARGETS_PY := generate-make-targets.py
TARGETS_FILE := targets.makefile
TSV_FILENAME := websites.tsv

# flywheel stuff
LOCAL_PATH_PREFIX := ~/www
FLYWHEEL_PATH := /www

WP_CONTENT_DIR := wp-content
WP_PLUGINS_DIR := plugins
WP_THEMES_DIR := themes

# precede command with "-" to continue even upon encountering an error
# precede a command with "@" to silence output

# use git to pull the freshest branch.
# $1 = remote ssh host (often an alias defined in ~/.ssh/config)
# $2 = subdirectory on the remote server (usually domain.org)
# $3 = wp-content subdirectory (themes/plugins). could be inferred from asset path in the future.
# $4 = plugin or theme path (whatever.org-plugin or whatever.org-theme)
# FIXME: I changed the order of arguments, but not the function calls.
# NOTE: this is deprecated, since the other function works for older and newer versions of git.
##define remote_git
##	@echo executing function \"$0\" for $(4)...
##	$(SSH) $(1) $(REMOTE_GIT) $(REMOTE_GIT_ARG) $(2)/$(WP_CONTENT_DIR)/$(3)/$(4) $(GIT_COMMAND) $(GIT_REMOTE) $(GIT_BRANCH)
##	@echo
##endef


# $1 = remote ssh host (often an alias defined in ~/.ssh/config)
# $2 = subdirectory on the remote server (usually domain.org)
# $3 = wp-content subdirectory (themes/plugins). could be inferred from asset path in the future.
# $4 = plugin or theme path (whatever.org-plugin or whatever.org-theme)
# $5 = git remote
# $6 = git branch
# for git where we have to cd into a local directory.
# FIXME: check return value of SSH command.
define git_cd
	@echo executing function \"$0\" for $(4)...
	$(SSH) $(1) cd $(2)/$(WP_CONTENT_DIR)/$(3)s/$(4) \&\& $(REMOTE_GIT) $(GIT_COMMAND) $(5) $(6)
	@echo
endef

# $1 = remote ssh host (often an alias defined in ~/.ssh/config)
# $2 = local subdirectory (~/www/domain.test)
# $3 = wp-content subdirectory (themes/plugins)
# $4 = plugin or theme path (whatever.org-plugin or whatever.org-theme)
# for rsync (where we can't use git, for whatever reason).
# these commands are not in a shell loop and don't need "special" treatment.
# FIXME: check if local subfolder exists.
define rsync
	@echo executing function \"$0\" for $(4)...
	$(RSYNC) -a --exclude-from=$(EXCLUDE) --verbose --progress --rsh=ssh $(LOCAL_PATH_PREFIX)/$(2)/$(WP_CONTENT_DIR)/$(3)s/$(4)/ $(1):$(FLYWHEEL_PATH)/$(WP_CONTENT_DIR)/$(3)s/$(4)/
	@echo
endef

# $1 = remote ssh host (often an alias defined in ~/.ssh/config)
# $2 = subdirectory on the remote server (usually domain.org)
# $3 = wp cli subcommand ("theme" or "plugin")
# $4 = plugin or theme path (whatever.org-plugin or whatever.org-theme)
define wp
	@echo executing function \"$0\" for $(4)...
	$(WP) --ssh=$(1) --path=$(2) $(3) $(WP_COMMAND) $(4)
	@echo
endef

# usage function. print help text.
define print_usage
	@$(ECHO) usage: make \<client_code\>
	@$(ECHO) usage: make \<website\>
	@$(ECHO) usage: make bdsl
	@$(ECHO) usage: make get-targets
	@$(ECHO)
	@$(ECHO) "websites:       $(TSV_FILENAME)"
	@$(ECHO)
	@$(ECHO) "all targets:    $(subst $(HOME),~,$(MAKEFILE_DIR))$(TARGETS_FILE)"
	@$(ECHO)
	@$(ECHO) "local targets:  ./$(TARGETS_FILE)"
	@$(ECHO)
endef


# default target. the first one in a Makefile is executed when no target is specified.
.PHONY: usage
usage:
	@$(ECHO) 
	@$(ECHO) No target specified.
	@$(ECHO) 
	$(call print_usage)

# https://stackoverflow.com/questions/2122602/force-makefile-to-execute-script-before-building-targets
# runs every time make runs.
$(shell python3 $(MAKEFILE_DIR)$(GENERATE_MAKE_TARGETS_PY) $(MAKEFILE_DIR)$(TSV_FILENAME)> $(MAKEFILE_DIR)$(TARGETS_FILE))

# include generated targets from external file
include $(MAKEFILE_DIR)$(TARGETS_FILE)

# include any other custom targets in the current directory
# fail silently if not found
-include ./$(TARGETS_FILE)

.PHONY: get-targets
get-targets:
	@$(GREP) ':' $(MAKEFILE_DIR)$(TARGETS_FILE) | $(AWK) -F':' '{print $$1}' | $(SORT)
#	TODO: print prerequisites?
#	@$(GREP) ':' $(MAKEFILE_DIR)$(TARGETS_FILE) | $(AWK) -F':' '{print $$2}' | $(SORT)

# use static pattern rule to substitute % for target name.
# https://www.gnu.org/software/make/manual/make.html#Static-Pattern
# https://stackoverflow.com/questions/16262344/pass-a-target-name-to-dependency-list-in-makefile
# note: only first % instance is substituted 
# sowa.massart.edu: % : sowa/%/plugin/sowa.massart.edu-plugin//git sowa/%/theme/sowa.massart.edu-theme//git

# catch all targets that end in "/git"
.PHONY: %/git
%/git:
	@echo
	@echo target: $@
	@echo

	$(eval target := $(subst /, ,$@))

#	do we have 5 arguments?
	$(if $(filter 5,$(words $(target))), \
	, \
	$(error Incorrect number of arguments in target))
	
	$(eval remote_host := $(firstword $(target)))
	$(eval remote_subdirectory := $(word 2,$(target)))
	$(eval asset_type := $(word 3,$(target)))
	$(eval asset_path := $(word 4,$(target)))

	$(call git_cd,$(remote_host),${remote_subdirectory},$(asset_type),$(asset_path),$(GIT_REMOTE),$(GIT_BRANCH))


# catch all targets that end in "/rsync"
.PHONY: %/rsync
%/rsync:
	@echo
	@echo target: $@
	@echo
	
	$(eval target := $(subst /, ,$@))

#	do we have 5 arguments?
	$(if $(filter 5,$(words $(target))), \
	, \
	$(error Incorrect number of arguments in target))

	$(eval remote_host := $(firstword $(target)))
	$(eval local_subfolder := $(word 2,$(target)))
	$(eval asset_type := $(word 3,$(target)))
	$(eval asset_path := $(word 4,$(target)))

	$(call rsync,$(remote_host),$(local_subfolder),$(asset_type),$(asset_path))

# catch all targets that end in "/wp"
.PHONY: %/wp
%/wp:
	@echo
	@echo target: $@
	@echo

	$(eval target := $(subst /, ,$@))

#	do we have 5 arguments?
	$(if $(filter 5,$(words $(target))), \
	, \
	$(error Incorrect number of arguments in target))

	$(eval remote_host := $(firstword $(target)))
	$(eval local_subfolder := $(word 2,$(target)))
	$(eval asset_type := $(word 3,$(target)))
	$(eval asset_path := $(word 4,$(target)))

	$(call wp,$(remote_host),$(local_subfolder),$(asset_type),$(asset_path))

