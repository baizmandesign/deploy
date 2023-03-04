SHELL = /bin/sh
SCP = /usr/bin/scp
SSH = /usr/bin/ssh
GIT = /usr/local/bin/git
LOCAL_GIT = git
ECHO = /bin/echo
RSYNC = /usr/bin/rsync
MAKE = /usr/bin/make
GIT_REMOTE = origin
GIT_BRANCH = production
GIT_BRANCH_OLD = master

LTA_DREAMHOST_SSH_HOST = cap
LTA_BLUEHOST_SSH_HOST = lta

# TODO: make these paths dynamic, somehow
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

 
826_FLYWHEEL_SSH_HOST = 826-prod
PCE_FLYWHEEL_SSH_HOST = pce-prod

BDSL_PATH = baizman-design-standard-library

WP_CONTENT_DIR = wp-content
WP_PLUGINS_DIR = ${WP_CONTENT_DIR}/plugins
WP_THEMES_DIR = ${WP_CONTENT_DIR}/themes

# some can use git -C

# some have to use scp (or rsync?)

# one makefile for all projects?
# one makefile for each repo?
# one makefile for each website?
# 
# BDSL_PATH: directory name (or shortcut)

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

bdsl: lta-dreamhost-bdsl-beagefriendly.org lta-dreamhost-bdsl-creativeagingportal.org lta-dreamhost-bdsl-creativeagingresource.org lta-dreamhost-bdsl-nyccreativeaginginitiative.org lta-bluehost-bdsl-lifetimearts.org lta-bluehost-bdsl-creativeagingtoolkit.org

lta: beagefriendly.org creativeagingresource.org creativeagingportal.org nyccreativeaginginitiative.org lifetimearts.org creativeagingtoolkit.org

beagefriendly.org: lta-dreamhost-bdsl-beagefriendly.org lta-dreamhost-plugin-beagefriendly.org lta-dreamhost-theme-beagefriendly.org
	true
	
creativeagingresource.org: lta-dreamhost-bdsl-creativeagingresource.org lta-dreamhost-plugin-creativeagingresource.org lta-dreamhost-theme-creativeagingresource.org
	true
	
creativeagingportal.org: lta-dreamhost-bdsl-creativeagingportal.org lta-dreamhost-plugin-creativeagingportal.org lta-dreamhost-theme-creativeagingportal.org
	true
	
nyccreativeaginginitiative.org: lta-dreamhost-bdsl-nyccreativeaginginitiative.org lta-dreamhost-plugin-nyccreativeaginginitiative.org lta-dreamhost-theme-nyccreativeaginginitiative.org
	true

lifetimearts.org: lta-bluehost-bdsl-lifetimearts.org lta-bluehost-plugin-lifetimearts.org lta-bluehost-theme-lifetimearts.org
	true

creativeagingtoolkit.org: lta-bluehost-bdsl-creativeagingtoolkit.org lta-bluehost-theme-creativeagingtoolkit.org
	true

lta-dreamhost-bdsl-%: 
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C dev.${@:lta-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C staging.${@:lta-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}

# for bluehost, it doesn't recognize the -C argument for git, so we cd into the directory.
lta-bluehost-bdsl-%:
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd dev.${@:lta-bluehost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd staging.${@:lta-bluehost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH}

lta-dreamhost-plugin-beagefriendly.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${BAF_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}

lta-dreamhost-plugin-creativeagingresource.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${CAR_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-plugin-creativeagingportal.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${CAP_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-plugin-nyccreativeaginginitiative.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${NYCCAI_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-theme-beagefriendly.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-theme-%=%}/${WP_THEME_DIR}/${BAF_THEME_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}

lta-dreamhost-theme-creativeagingresource.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-theme-%=%}/${WP_THEME_DIR}/${CAR_THEME_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-theme-creativeagingportal.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-theme-%=%}/${WP_THEME_DIR}/${CAP_THEME_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-theme-nyccreativeaginginitiative.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-theme-%=%}/${WP_THEME_DIR}/${NYCCAI_THEME_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

# for bluehost, it doesn't recognize the -C argument for git, so we cd into the directory.
lta-bluehost-plugin-lifetimearts.org:
	#${RSYNC} -a --verbose --progress --rsh=ssh ${LTA_BLUEHOST_SSH_HOST}:${@:lta-bluehost-plugin-%=%}/${WP_PLUGINS_DIR}/${LTA_PLUGIN_PATH}/ ${LTA_PATH_LOCAL}/${WP_PLUGINS_DIR}/${LTA_PLUGIN_PATH}/
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-plugin-%=%}/${WP_PLUGINS_DIR}/${LTA_PLUGIN_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}
	
lta-bluehost-theme-lifetimearts.org:
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-theme-%=%}/${WP_THEMES_DIR}/${LTA_THEME_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}
	
	
lta-bluehost-theme-creativeagingtoolkit.org:
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-theme-%=%}/${WP_THEMES_DIR}/${CAT_THEME_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}
	
	
#lta-dreamhost-plugin-%:
#	if \
#	[[ ${@:lta-dreamhost-plugin-%=%} == 'creativeagingresource.org' ]] ; \
#	then \
#	plugin_dir=car-plugin ; \
#	fi
	
#	echo ${@:lta-dreamhost-plugin-%=%}
#	echo updating plugin...
	
#lta-dreamhost-theme-%:
#	echo ${@:lta-dreamhost-theme-%=%}
#	echo updating theme...

lta-bluehost-plugin-%:
	echo ${@:lta-dreamhost-plugin-%=%}
	echo updating plugin...
	
lta-bluehost-theme-%:
	echo ${@:lta-dreamhost-theme-%=%}
	echo updating theme...

826b: 
	@ ${ECHO} 
	@ ${ECHO} Deploying on $@...
	@ ${ECHO}

pce:
	@ ${ECHO} 
	@ ${ECHO} Deploying on $@...
	@ ${ECHO}

bzmn:
	@ ${ECHO} 
	@ ${ECHO} Deploying on $@...
	@ ${ECHO}

flywheel: pce 826b
	@ ${ECHO} 
	@ ${ECHO} Deploying on $@...
	@ ${ECHO}

bluehost: 
	@ ${ECHO} 
	@ ${ECHO} Deploying on $@...
	@ ${ECHO} 

dreamhost:
	@ ${ECHO} 
	@ ${ECHO} Deploying on $@...
	@ ${ECHO} 

# https://stackoverflow.com/questions/64839635/how-to-pass-argument-to-BDSL_PATH-in-makefile
#test-%:
#	echo $@
#	echo $(@:test-%=%)