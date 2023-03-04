# this makefile is for deploying multiple projects across multiple clients' websites.
# it requires ssh public-key authentication on the ssh remote hosts.

# FIXME: i can simplify this by using name substitution and target names to pass "variables" in the parts of the target.
# i could also renamed the plugins and themes to have standard names:
# website.org-plugin
# website.org-theme

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

# baizman design (dreamhost)
BZMN_PLUGIN_PATH = baizmandesign.com-plugin
BZMN_THEME_PATH = baizmandesign.com-theme

# personal site (dreamhost)
SB_PLUGIN_PATH = saulbaizman.com-plugin
SB_THEME_PATH = saulbaizman.com-theme


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
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C dev.${@:lta-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C staging.${@:lta-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}

# for bluehost, it doesn't recognize the -C argument for git, so we cd into the directory.
lta-bluehost-bdsl-%:
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd dev.${@:lta-bluehost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd staging.${@:lta-bluehost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH}

lta-dreamhost-plugin-beagefriendly.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${BAF_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}

lta-dreamhost-plugin-creativeagingresource.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${CAR_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-plugin-creativeagingportal.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${CAP_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-plugin-nyccreativeaginginitiative.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-plugin-%=%}/${WP_PLUGINS_DIR}/${NYCCAI_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-theme-beagefriendly.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-theme-%=%}/${WP_THEMES_DIR}/${BAF_THEME_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}

lta-dreamhost-theme-creativeagingresource.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-theme-%=%}/${WP_THEMES_DIR}/${CAR_THEME_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-theme-creativeagingportal.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-theme-%=%}/${WP_THEMES_DIR}/${CAP_THEME_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-dreamhost-theme-nyccreativeaginginitiative.org:
	${SSH} ${LTA_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:lta-dreamhost-theme-%=%}/${WP_THEMES_DIR}/${NYCCAI_THEME_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

# for bluehost, it doesn't recognize the -C argument for git, so we cd into the directory.
lta-bluehost-plugin-lifetimearts.org:
	#${RSYNC} -a --verbose --progress --rsh=ssh ${LTA_PATH_LOCAL}/${WP_PLUGINS_DIR}/${LTA_PLUGIN_PATH}/ ${LTA_BLUEHOST_SSH_HOST}:${@:lta-bluehost-plugin-%=%}/${WP_PLUGINS_DIR}/${LTA_PLUGIN_PATH}/
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-plugin-%=%}/${WP_PLUGINS_DIR}/${LTA_PLUGIN_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}
	
lta-bluehost-theme-lifetimearts.org:
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-theme-%=%}/${WP_THEMES_DIR}/${LTA_THEME_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

lta-bluehost-theme-creativeagingtoolkit.org:
	${SSH} ${LTA_BLUEHOST_SSH_HOST} cd ${@:lta-bluehost-theme-%=%}/${WP_THEMES_DIR}/${CAT_THEME_PATH} \&\& ${LOCAL_GIT} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}
	
	
#lta-dreamhost-plugin-%:
# true

#lta-dreamhost-theme-%:
#	echo ${@:lta-dreamhost-theme-%=%}
#	echo updating theme...

#lta-bluehost-plugin-%:
#	echo ${@:lta-dreamhost-plugin-%=%}
#	echo updating plugin...

#lta-bluehost-theme-%:
#	echo ${@:lta-dreamhost-theme-%=%}
#	echo updating theme...

826b: 826boston.org
	true

pce: pce.massart.edu
	true

pce.massart.edu: pce-flywheel-bdsl-pce.massart.edu pce-flywheel-plugin-pce.massart.edu pce-flywheel-theme-pce.massart.edu

# we have to use rsync / ssh because git is disabled on flywheel.
pce-flywheel-bdsl-pce.massart.edu:
	${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${BDSL_PATH_LOCAL}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH}/ ${PCE_FLYWHEEL_SSH_HOST}:${FLYWHEEL_PATH}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH}/

pce-flywheel-plugin-pce.massart.edu:
	${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${PCE_PATH_LOCAL}/${WP_PLUGINS_DIR}/${PCE_PLUGIN_PATH}/ ${PCE_FLYWHEEL_SSH_HOST}:${FLYWHEEL_PATH}/${WP_PLUGINS_DIR}/${PCE_PLUGIN_PATH}/

pce-flywheel-theme-pce.massart.edu:
	${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${PCE_PATH_LOCAL}/${WP_THEMES_DIR}/${PCE_THEME_PATH}/ ${PCE_FLYWHEEL_SSH_HOST}:${FLYWHEEL_PATH}/${WP_THEMES_DIR}/${PCE_THEME_PATH}/

826boston.org: 826-flywheel-bdsl-826boston.org 826-flywheel-theme-826boston.org
	true

826-flywheel-bdsl-826boston.org:
	${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${BDSL_PATH_LOCAL}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH}/ ${826_FLYWHEEL_SSH_HOST}:${FLYWHEEL_PATH}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH}/

826-flywheel-theme-826boston.org:
	${RSYNC} -a --exclude-from=${EXCLUDE} --verbose --progress --rsh=ssh ${826_PATH_LOCAL}/${WP_THEMES_DIR}/${826_THEME_PATH}/ ${826_FLYWHEEL_SSH_HOST}:${FLYWHEEL_PATH}/${WP_THEMES_DIR}/${826_THEME_PATH}/

bzmn: baizmandesign.com saulbaizman.com
	true

baizmandesign.com: bzmn-dreamhost-bdsl-baizmandesign.com bzmn-dreamhost-plugin-baizmandesign.com bzmn-dreamhost-theme-baizmandesign.com
	true

bzmn-dreamhost-bdsl-baizmandesign.com:
	${SSH} ${BZMN_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:bzmn-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${BZMN_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C dev.${@:bzmn-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}

bzmn-dreamhost-plugin-baizmandesign.com:
	${SSH} ${BZMN_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:bzmn-dreamhost-plugin-%=%}/${WP_CONTENT_DIR}/${@:bzmn-dreamhost-%-baizmandesign.com=%}s/${BZMN_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${BZMN_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C dev.${@:bzmn-dreamhost-plugin-%=%}/${WP_CONTENT_DIR}/${@:bzmn-dreamhost-%-baizmandesign.com=%}s/${BZMN_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}
	
bzmn-dreamhost-theme-baizmandesign.com:
	${SSH} ${BZMN_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:bzmn-dreamhost-theme-%=%}/${WP_CONTENT_DIR}/${@:bzmn-dreamhost-%-baizmandesign.com=%}s/${BZMN_THEME_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${BZMN_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C dev.${@:bzmn-dreamhost-theme-%=%}/${WP_CONTENT_DIR}/${@:bzmn-dreamhost-%-baizmandesign.com=%}s/${BZMN_THEME_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}

saulbaizman.com: sb-dreamhost-bdsl-saulbaizman.com sb-dreamhost-plugin-saulbaizman.com sb-dreamhost-theme-saulbaizman.com
	true

sb-dreamhost-bdsl-saulbaizman.com:
	${SSH} ${SB_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:sb-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}
	${SSH} ${SB_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C dev.${@:sb-dreamhost-bdsl-%=%}/${WP_PLUGINS_DIR}/${BDSL_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH}

sb-dreamhost-plugin-saulbaizman.com:
	${SSH} ${SB_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:sb-dreamhost-plugin-%=%}/${WP_CONTENT_DIR}/${@:sb-dreamhost-%-saulbaizman.com=%}s/${SB_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}
	${SSH} ${SB_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C dev.${@:sb-dreamhost-plugin-%=%}/${WP_CONTENT_DIR}/${@:sb-dreamhost-%-saulbaizman.com=%}s/${SB_PLUGIN_PATH} pull ${GIT_REMOTE} ${GIT_BRANCH_OLD}

sb-dreamhost-theme-saulbaizman.com:
	# note: the branch is neither master nor production 
	${SSH} ${SB_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C ${@:sb-dreamhost-theme-%=%}/${WP_CONTENT_DIR}/${@:sb-dreamhost-%-saulbaizman.com=%}s/${SB_THEME_PATH} pull ${GIT_REMOTE} feature/typeface
	${SSH} ${SB_DREAMHOST_SSH_HOST} ${LOCAL_GIT} -C dev.${@:sb-dreamhost-theme-%=%}/${WP_CONTENT_DIR}/${@:sb-dreamhost-%-saulbaizman.com=%}s/${SB_THEME_PATH} pull ${GIT_REMOTE} feature/typeface

ane: ane.massart.edu
	true

ane.massart.edu:
	true	

sowa: sowa.massart.edu
	true

sowa.massart.edu
	true

flywheel: pce 826b
	true

bluehost:
	true

dreamhost:
	true

# https://stackoverflow.com/questions/64839635/how-to-pass-argument-to-BDSL_PLUGIN_PATH-in-makefile
#test-%:
#	echo $@
#	echo $(@:test-%=%)

#test2: test3-${@}

#test3-test2:
#	echo $@
#test4:
#	@ echo $@
