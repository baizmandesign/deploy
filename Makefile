# this makefile is for deploying multiple projects across multiple clients' websites.
# it requires ssh public-key authentication on the ssh remote hosts.

# FIXME: i can simplify this by using name substitution and target names to pass "variables" in the parts of the target.
# i could also renamed the plugins and themes to have standard names:
# website.org-plugin
# website.org-theme

SHELL = /bin/sh
SSH = /usr/bin/ssh
REMOTE_GIT = git
REMOTE_GIT_ARG = -C
ECHO = /bin/echo
RSYNC = /usr/bin/rsync
GIT_COMMAND = pull
GIT_REMOTE = origin
GIT_BRANCH = production
GIT_BRANCH_OLD = master
# https://stackoverflow.com/questions/2004760/get-makefile-directory
makeFileDir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
EXCLUDE = ${makeFileDir}excluded.txt

LTA_DREAMHOST_SSH_HOST = cap
LTA_BLUEHOST_SSH_HOST = lta

BZMN_DREAMHOST_SSH_HOST = bd
SB_DREAMHOST_SSH_HOST = b

# TODO: make these paths dynamic, somehow. maybe look them up in the Tower SQLite database?
BAF_PLUGIN_PATH = baf-plugin
BAF_THEME_PATH = dhyana
CAR_PLUGIN_PATH = car-plugin
CAR_THEME_PATH = car-theme
CAP_PLUGIN_PATH = creative-aging-portal-plugin
CAP_THEME_PATH = creative-aging-portal-theme
NYCCAI_PLUGIN_PATH = nyccai-plugin
NYCCAI_THEME_PATH = nyccai
LTA_PLUGIN_PATH = lifetime-arts-plugin
LTA_PATH_LOCAL = ~/www/lta.test
LTA_THEME_PATH = lifetime-arts-theme
CAT_THEME_PATH = creativeagingtoolkit-sunset
CAT_PATH_LOCAL = ~/www/cat.test

# flywheel
826_FLYWHEEL_SSH_HOST = 826-prod
PCE_FLYWHEEL_SSH_HOST = pce-prod
FLYWHEEL_PATH = /www
PCE_PLUGIN_PATH = pce-plugin
PCE_THEME_PATH = pce-theme
PCE_PATH_LOCAL = ~/www/pce.test
826_THEME_PATH = yetti
826_PATH_LOCAL = ~/www/826boston.test

BDSL_PLUGIN_PATH = baizman-design-standard-library
BDSL_PATH_LOCAL = ~/www/bd.test

WP_CONTENT_DIR = wp-content
WP_PLUGINS_DIR = ${WP_CONTENT_DIR}/plugins
WP_THEMES_DIR = ${WP_CONTENT_DIR}/themes

# some can use git -C

# some have to use scp (or rsync?)

# one makefile for all projects?
# one makefile for each repo?
# one makefile for each website?

# precede command with "-" to continue even upon encountering an error
# precede a command with "@" to silence output

# use patterns?

usage:
	@ ${ECHO} 
	@ ${ECHO} No target specified.
	@ ${ECHO} 
	@ ${ECHO} $@: make \<client_code\>
	@ ${ECHO} $@: make \<website\>
	@ ${ECHO} $@: make bdsl
	@ ${ECHO}
	
all: lta 826b pce bzmn

bdsl: lta-dreamhost-bdsl-beagefriendly.org lta-dreamhost-bdsl-creativeagingportal.org lta-dreamhost-bdsl-creativeagingresource.org lta-dreamhost-bdsl-nyccreativeaginginitiative.org lta-bluehost-bdsl-lifetimearts.org lta-bluehost-bdsl-creativeagingtoolkit.org pce-flywheel-bdsl-pce.massart.edu 826-flywheel-bdsl-826boston.org bzmn-dreamhost-bdsl-baizmandesign.com sb-dreamhost-bdsl-saulbaizman.com

lta: beagefriendly.org creativeagingresource.org creativeagingportal.org nyccreativeaginginitiative.org lifetimearts.org creativeagingtoolkit.org

beagefriendly.org: lta-dreamhost-bdsl-beagefriendly.org lta-dreamhost-plugin-beagefriendly.org lta-dreamhost-theme-beagefriendly.org
	
creativeagingresource.org: lta-dreamhost-bdsl-creativeagingresource.org lta-dreamhost-plugin-creativeagingresource.org lta-dreamhost-theme-creativeagingresource.org
	
creativeagingportal.org: lta-dreamhost-bdsl-creativeagingportal.org lta-dreamhost-plugin-creativeagingportal.org lta-dreamhost-theme-creativeagingportal.org
	
nyccreativeaginginitiative.org: lta-dreamhost-bdsl-nyccreativeaginginitiative.org lta-dreamhost-plugin-nyccreativeaginginitiative.org lta-dreamhost-theme-nyccreativeaginginitiative.org

lifetimearts.org: lta-bluehost-bdsl-lifetimearts.org lta-bluehost-plugin-lifetimearts.org lta-bluehost-theme-lifetimearts.org

creativeagingtoolkit.org: lta-bluehost-bdsl-creativeagingtoolkit.org lta-bluehost-theme-creativeagingtoolkit.org

lta-dreamhost-bdsl-%: 
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${@:lta-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} dev.${@:lta-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} staging.${@:lta-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}

# for bluehost, it doesn't recognize the ${REMOTE_GIT_ARG} argument for git, so we cd into the directory.
lta-bluehost-bdsl-%:
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} \&\& ${REMOTE_GIT} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd dev.${@:lta-bluehost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} \&\& ${REMOTE_GIT} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd staging.${@:lta-bluehost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} \&\& ${REMOTE_GIT} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}

lta-dreamhost-plugin-beagefriendly.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${BAF_PLUGIN_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}

lta-dreamhost-plugin-creativeagingresource.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${CAR_PLUGIN_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-plugin-creativeagingportal.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${CAP_PLUGIN_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-plugin-nyccreativeaginginitiative.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${NYCCAI_PLUGIN_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-theme-beagefriendly.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${@:lta-dreamhost-theme-%=%}/${WP_THEMES_DIR}/${BAF_THEME_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}

lta-dreamhost-theme-creativeagingresource.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${@:lta-dreamhost-theme-%=%}/${WP_THEMES_DIR}/${CAR_THEME_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-theme-creativeagingportal.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${@:lta-dreamhost-theme-%=%}/${WP_THEMES_DIR}/${CAP_THEME_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-theme-nyccreativeaginginitiative.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${@:lta-dreamhost-theme-%=%}/${WP_THEMES_DIR}/${NYCCAI_THEME_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH_OLD}

# for bluehost, it doesn't recognize the ${REMOTE_GIT_ARG} argument for git, so we cd into the directory.
lta-bluehost-plugin-lifetimearts.org:
	#${RSYNC} -a --verbose --progress --rsh=ssh ${LTA_PATH_LOCAL}/${WP_PLUGINS_DIR}/${LTA_PLUGIN_PATH}/ ${LTA_BLUEHOST_SSH_HOST}:${@:lta-bluehost-plugin-%=%}/${WP_PLUGINS_DIR}/${LTA_PLUGIN_PATH}/
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-plugin-%=%}/${WP_PLUGINS_DIR}/${LTA_PLUGIN_PATH} \&\& ${REMOTE_GIT} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH_OLD}
	
lta-bluehost-theme-lifetimearts.org:
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-theme-%=%}/${WP_THEMES_DIR}/${LTA_THEME_PATH} \&\& ${REMOTE_GIT} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-bluehost-theme-creativeagingtoolkit.org:
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-theme-%=%}/${WP_THEMES_DIR}/${CAT_THEME_PATH} \&\& ${REMOTE_GIT} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH_OLD}
	
	
#lta-dreamhost-plugin-%:

#lta-dreamhost-theme-%:

#lta-bluehost-plugin-%:

#lta-bluehost-theme-%:

826b: 826boston.org

pce: pce.massart.edu

pce.massart.edu: pce-flywheel-bdsl-pce.massart.edu pce-flywheel-plugin-pce.massart.edu pce-flywheel-theme-pce.massart.edu

# we have to use rsync / ssh because git is disabled on flywheel.
pce-flywheel-bdsl-pce.massart.edu:
	${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${BDSL_PATH_LOCAL}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH}/ ${PCE_FLYWHEEL_SSH_HOST}:${FLYWHEEL_PATH}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH}/

pce-flywheel-plugin-pce.massart.edu:
	${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${PCE_PATH_LOCAL}/${WP_PLUGINS_DIR}/${PCE_PLUGIN_PATH}/ ${PCE_FLYWHEEL_SSH_HOST}:${FLYWHEEL_PATH}/${WP_PLUGINS_DIR}/${PCE_PLUGIN_PATH}/

pce-flywheel-theme-pce.massart.edu:
	${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${PCE_PATH_LOCAL}/${WP_THEMES_DIR}/${PCE_THEME_PATH}/ ${PCE_FLYWHEEL_SSH_HOST}:${FLYWHEEL_PATH}/${WP_THEMES_DIR}/${PCE_THEME_PATH}/

826boston.org: 826-flywheel-bdsl-826boston.org 826-flywheel-theme-826boston.org

826-flywheel-bdsl-826boston.org:
	${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${BDSL_PATH_LOCAL}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH}/ ${826_FLYWHEEL_SSH_HOST}:${FLYWHEEL_PATH}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH}/

826-flywheel-theme-826boston.org:
	${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${826_PATH_LOCAL}/${WP_THEMES_DIR}/${826_THEME_PATH}/ ${826_FLYWHEEL_SSH_HOST}:${FLYWHEEL_PATH}/${WP_THEMES_DIR}/${826_THEME_PATH}/

bzmn: baizmandesign.com saulbaizman.com

baizmandesign.com: bzmn-dreamhost-bdsl-baizmandesign.com bzmn-dreamhost-plugin-baizmandesign.com bzmn-dreamhost-theme-baizmandesign.com

bzmn-dreamhost-bdsl-baizmandesign.com:
	${SSH} ${BZMN_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${@:bzmn-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${BZMN_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} dev.${@:bzmn-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}

# https://stackoverflow.com/questions/34888725/setting-makefile-variable-to-result-of-command-in-rule
bzmn-dreamhost-%-baizmandesign.com:
	${eval domain = ${subst theme-,,${subst plugin-,,${patsubst bzmn-dreamhost-%,%,$@}}}}
	${eval suffix = ${@:bzmn-dreamhost-%-baizmandesign.com=%}}
	${eval subdir = ${suffix}s}
	for site in ${domain} dev.${domain} ; do \
${SSH} ${BZMN_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} $$site/${WP_CONTENT_DIR}/${subdir}/${domain}-${suffix} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH} ; \
done

saulbaizman.com: sb-dreamhost-bdsl-saulbaizman.com sb-dreamhost-plugin-saulbaizman.com sb-dreamhost-theme-saulbaizman.com

sb-dreamhost-bdsl-saulbaizman.com:
	${SSH} ${SB_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} ${@:sb-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${SB_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} dev.${@:sb-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH}

sb-dreamhost-%-saulbaizman.com:
	${eval domain = ${subst theme-,,${subst plugin-,,${patsubst sb-dreamhost-%,%,$@}}}}
	${eval suffix = ${@:sb-dreamhost-%-saulbaizman.com=%}}
	${eval subdir = ${suffix}s}
	for site in ${domain} dev.${domain} ; do \
${SSH} ${SB_DREAMHOST_SSH_HOST} ${REMOTE_GIT} ${REMOTE_GIT_ARG} $$site/${WP_CONTENT_DIR}/${subdir}/${domain}-${suffix} ${GIT_COMMAND} ${GIT_REMOTE} ${GIT_BRANCH} ; \
done


ane: ane.massart.edu

ane.massart.edu:
	true	

sowa: sowa.massart.edu

sowa.massart.edu:
	true

flywheel: pce 826b

bluehost:
	true

dreamhost:
	true

