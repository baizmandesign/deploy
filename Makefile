# this makefile is for deploying multiple projects across multiple clients' websites.
# it requires ssh public-key authentication on the ssh remote hosts.
# add new websites in generate-make-targets.py


SHELL = /bin/sh
SSH = /usr/bin/ssh
REMOTE_GIT = git
REMOTE_GIT_ARG = -C
ECHO = /bin/echo
RSYNC = /usr/bin/rsync
GREP = /usr/bin/grep
AWK = /usr/bin/awk
SORT = /usr/bin/sort
GIT_COMMAND = pull
GIT_REMOTE = origin
GIT_BRANCH = production
# https://stackoverflow.com/questions/2004760/get-makefile-directory
MAKEFILE_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
EXCLUDE = ${MAKEFILE_DIR}excluded.txt
GENERATE_MAKE_TARGETS_PY = generate-make-targets.py
TARGETS_FILE = targets.makefile
COMMA := ,


# flywheel stuff
LOCAL_PATH_PREFIX = ~/www
FLYWHEEL_PATH = /www
BDSL_PATH_LOCAL = bd.test

WP_CONTENT_DIR = wp-content
WP_PLUGINS_DIR = plugins
WP_THEMES_DIR = themes

# precede command with "-" to continue even upon encountering an error
# precede a command with "@" to silence output

# use git to pull the freshest branch.
# $1 = remote ssh host
# $2 = subdirectory on the remote server (usually domain.org)
# $3 = wp-content subdirectory (themes/plugins). could be inferred from asset path in the future.
# $4 = plugin path (whatever.org-plugin) / theme path (whatever.org-theme)
# this function is called from within a for loop, and therefore requires the terminating ; and \.
# if it were called outside a for loop, it would not need those characters. plus, other make conventions would work (like pre-pending an @ symbol).
# FIXME: I changed the order of arguments, but not the function calls.
# NOTE: this is deprecated, since the other function works for older and newer versions of git.
##define remote_git
##	echo executing remote_git... ; \
##	echo ${SSH} ${1} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${2}/${WP_CONTENT_DIR}/${3}/${4} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH} ; \
##	echo
##endef


# $1 = remote ssh host
# $2 = subdirectory on the remote server (usually domain.org)
# $3 = wp-content subdirectory (themes/plugins). could be inferred from asset path in the future.
# $4 = plugin or theme path
# for git where we have to cd into a local directory.
# FIXME: check return value of SSH command.
define git_cd
	echo executing git_cd... ; \
	echo ${SSH} ${1} cd ${2}/${WP_CONTENT_DIR}/${3}s/${4} \&\& ${REMOTE_GIT} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH} ; \
	${SSH} ${1} cd ${2}/${WP_CONTENT_DIR}/${3}s/${4} \&\& ${REMOTE_GIT} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH} ; \
	echo
endef

# $1 = remote ssh host
# $2 = local subdirectory (~/www/domain.test)
# $3 = wp-content subdirectory (themes/plugins)
# $4 = plugin or theme path
# for rsync (where we can't use git, for whatever reason).
# these commands are not in a shell loop and don't need "special" treatment.
# FIXME: check if local subfolder exists.
define rsync
	@ echo executing rsync for ${4}...
	@ echo ${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${LOCAL_PATH_PREFIX}/${2}/${WP_CONTENT_DIR}/${3}s/${4}/ ${1}:${FLYWHEEL_PATH}/${WP_CONTENT_DIR}/${3}s/${4}/
	@ ${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${LOCAL_PATH_PREFIX}/${2}/${WP_CONTENT_DIR}/${3}s/${4}/ ${1}:${FLYWHEEL_PATH}/${WP_CONTENT_DIR}/${3}s/${4}/
	@ echo
endef

# default target (first one in Makefile executed when to targets are specified).
# usage function. print help text.
define print_usage
	@ ${ECHO} usage: make \<client_code\>
	@ ${ECHO} usage: make \<website\>
	@ ${ECHO} usage: make bdsl
	@ ${ECHO} usage: make get-targets
	@ ${ECHO}
	@ ${ECHO} see other valid targets in $(MAKEFILE_DIR)$(TARGETS_FILE).
	@ ${ECHO}
	@ ${ECHO} add additional targets in ./$(TARGETS_FILE).
	@ ${ECHO}
endef


# first target is default target.
usage:
	@ ${ECHO} 
	@ ${ECHO} No target specified.
	@ ${ECHO} 
	$(call print_usage)

# https://stackoverflow.com/questions/2122602/force-makefile-to-execute-script-before-building-targets
# runs every time make runs.
MAKE_TARGETS := $(shell python3 $(MAKEFILE_DIR)$(GENERATE_MAKE_TARGETS_PY) > $(MAKEFILE_DIR)$(TARGETS_FILE))

# include generated targets from external file
include $(MAKEFILE_DIR)$(TARGETS_FILE)

# include any other custom targets in the current directory
# fail silently if not found
-include ./$(TARGETS_FILE)

get-targets:
	@ $(GREP) ':' $(MAKEFILE_DIR)$(TARGETS_FILE) | $(AWK) -F':' '{print $$1}' | $(SORT)
#	TODO: print prerequisites?
#	@ $(GREP) ':' $(MAKEFILE_DIR)$(TARGETS_FILE) | $(AWK) -F':' '{print $$2}' | $(SORT)

# use static pattern rule to substitute % for target name.
# https://www.gnu.org/software/make/manual/make.html#Static-Pattern
# https://stackoverflow.com/questions/16262344/pass-a-target-name-to-dependency-list-in-makefile
# note: only first % instance is substituted 
# sowa.massart.edu: % : sowa/%/plugin/sowa.massart.edu-plugin//git sowa/%/theme/sowa.massart.edu-theme//git

# catch all targets that end in "/git"
%/git:
	@echo
	@echo target: $@
	@echo

	$(eval target := $(subst /, ,$@))

#	do we have 5 or 6 arguments? when the subdomain parameter is empty ("//"), we have one less argument than usual.
	$(if $(or $(filter 5,$(words $(target))), \
	$(filter 6,$(words $(target)))), \
	, \
	$(error Incorrect number of arguments in target))
	
	$(eval remote_host := $(firstword $(target)))
	$(eval remote_subdirectory := $(word 2,$(target)))
	$(eval asset_type := $(word 3,$(target)))
	$(eval asset_path := $(word 4,$(target)))
	$(eval subdomains_csv := $(word 5,$(target)))

	$(eval subdomains := $(subst $(COMMA), ,$(subdomains_csv)))

#	do we only have 5 arguments (no subdomains)? if so, set the subdomains to nothing. if not, create the proper subdomain list and the append domain name to each subdomain.	
	$(if $(filter 5,$(words $(target))),$(eval subdomains := ""), \
	$(eval subdomain_list := $(foreach sub, \
	$(subdomains),$(sub).$(remote_subdirectory))))

	for website in $(remote_subdirectory) $(subdomain_list) ; do \
		$(call git_cd,$(remote_host),$${website},$(asset_type),$(asset_path)) ; \
	done

# catch all targets that end in "/rsync"
%/rsync:
	@echo
	@echo target: $@
	@echo
	
	$(eval target := $(subst /, ,$@))

#	do we have 5 or 6 arguments? when the subdomain parameter is empty ("//"), we have one less argument than usual.
	$(if $(or $(filter 5,$(words $(target))), \
	$(filter 6,$(words $(target)))), \
	, \
	$(error Incorrect number of arguments in target))

	$(eval remote_host := $(firstword $(target)))
	$(eval local_subfolder := $(word 2,$(target)))
	$(eval asset_type := $(word 3,$(target)))
	$(eval asset_path := $(word 4,$(target)))
#	for whatever reason, we have no subdomains for the sites that use rsync.
	$(eval subdomains_csv := '')

	$(call rsync,$(remote_host),$(local_subfolder),$(asset_type),$(asset_path))
