# this makefile is for deploying multiple projects across multiple websites.
# see README.md for details.
# add new websites in websites.tsv.

# FIXME: a path is added to the "wp" command for flywheel sites, which shouldn't have one.

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
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
EXCLUDE := ${MAKEFILE_DIR}/excluded.txt
GENERATE_MAKE_TARGETS_PY := generate-make-targets.py
TARGETS_FILE ?= targets.makefile
TSV_FILENAME := websites.tsv

# flywheel stuff
RSYNC_LOCAL_PATH_PREFIX := ~/www
RSYNC_REMOTE_PATH_PREFIX := /www

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
# $5 = git remote
# $6 = git branch
# NOTE: this is deprecated, since git_cd works for older versions of git that do not understand the -C argument.
remote_git = $(SSH) $(1) $(REMOTE_GIT) $(REMOTE_GIT_ARG) $(2)/$(WP_CONTENT_DIR)/$(3)s/$(4) $(GIT_COMMAND) $(5) $(6)

# $1 = remote ssh host (often an alias defined in ~/.ssh/config)
# $2 = subdirectory on the remote server (usually domain.org)
# $3 = wp-content subdirectory (themes/plugins). could be inferred from asset path in the future.
# $4 = plugin or theme path (whatever.org-plugin or whatever.org-theme)
# $5 = git remote
# $6 = git branch
# for an older version of git where we have to cd into a local directory because it does not understand the -C argument.
git_cd = $(SSH) $(1) cd $(2)/$(WP_CONTENT_DIR)/$(3)s/$(4) \&\& $(REMOTE_GIT) $(GIT_COMMAND) $(5) $(6)

# $1 = remote ssh host (often an alias defined in ~/.ssh/config)
# $2 = local subdirectory (~/www/domain.test)
# $3 = wp-content subdirectory (themes/plugins)
# $4 = plugin or theme path (whatever.org-plugin or whatever.org-theme)
# for rsync (where we can't use git, for whatever reason).
# these commands are not in a shell loop and don't need "special" treatment.
# FIXME: check if local subfolder exists.
rsync = $(RSYNC) -a --exclude-from=$(EXCLUDE) --verbose --progress --rsh=ssh $(RSYNC_LOCAL_PATH_PREFIX)/$(2)/$(WP_CONTENT_DIR)/$(3)s/$(4)/ $(1):$(RSYNC_REMOTE_PATH_PREFIX)/$(WP_CONTENT_DIR)/$(3)s/$(4)/

# $1 = remote ssh host (often an alias defined in ~/.ssh/config)
# $2 = subdirectory on the remote server (usually domain.org)
# $3 = wp cli subcommand ("theme" or "plugin")
# $4 = plugin or theme path (whatever.org-plugin or whatever.org-theme)
# note: this does not use wp cli aliases, but it could.
wp = $(WP) --ssh=$(1) --path=$(2) $(3) $(WP_COMMAND) $(4)

# default target. the first target in a Makefile is usually executed when no target is specified, unless this variable is set.
# https://www.gnu.org/software/make/manual/html_node/Special-Variables.html
.DEFAULT_GOAL := usage

# https://stackoverflow.com/questions/2122602/force-makefile-to-execute-script-before-building-targets
# runs every time make runs. regenerates list of targets.
$(shell python3 $(MAKEFILE_DIR)/$(GENERATE_MAKE_TARGETS_PY) $(MAKEFILE_DIR)/$(TSV_FILENAME)> $(MAKEFILE_DIR)/$(TARGETS_FILE))

# include generated targets from external file.
include $(MAKEFILE_DIR)/$(TARGETS_FILE)

# include any other custom targets in the current directory.
# fail silently if not found.
-include ./$(TARGETS_FILE)

# get list of targets (but not pre-requisites, which are also targets).
.PHONY: get-targets
get-targets:
	@$(GREP) ':' $(MAKEFILE_DIR)/$(TARGETS_FILE) | $(GREP) -v 'PHONY' | $(AWK) -F':' '{print $$1}' | $(SORT)
#	TODO: print prerequisites?
#	@$(GREP) ':' $(MAKEFILE_DIR)/$(TARGETS_FILE) | $(AWK) -F':' '{print $$2}' | $(SORT)

# use static pattern rule to substitute % for target name.
# https://www.gnu.org/software/make/manual/make.html#Static-Pattern
# https://stackoverflow.com/questions/16262344/pass-a-target-name-to-dependency-list-in-makefile
# note: only first % instance is substituted 

# catch all targets that end in "/git".
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


# catch all targets that end in "/rsync".
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


# catch all targets that end in "/wp".
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


.PHONY: usage
usage:
	@$(ECHO) 
	@$(ECHO) No target specified.
	@$(ECHO) 
	@$(ECHO) usage: make \<client_code\>
	@$(ECHO) usage: make \<website\>
	@$(ECHO) usage: make bdsl
	@$(ECHO) usage: make get-targets
	@$(ECHO)
	@$(ECHO) "websites:       $(subst $(HOME),~,$(MAKEFILE_DIR))/$(TSV_FILENAME)"
	@$(ECHO)
	@$(ECHO) "all targets:    $(subst $(HOME),~,$(MAKEFILE_DIR))/$(TARGETS_FILE)"
	@$(ECHO)
	@$(ECHO) "local targets:  ./$(TARGETS_FILE)"
	@$(ECHO)
