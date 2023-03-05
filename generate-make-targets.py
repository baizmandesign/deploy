#!/usr/bin/env python3
# -*- coding: utf-8 -*-

'''
This program prints a list of make targets.
'''

PART_SEPARATOR = '/'
SUBDOMAIN_SEPARATOR = ','
SPACE = ' '
DEPENDENCY_SEPARATOR = SPACE
BDSL_PLUGIN_PATH = 'baizman-design-standard-library'
BDSL_PLUGIN = { 'type': 'plugin', 'path': BDSL_PLUGIN_PATH,}
LTA_DREAMHOST = 'cap'
LTA_BLUEHOST = 'lta'


def print_targets ( website_list ):
	# TODO: track webhosts
	# TODO: track clients
	# TODO: track sites with a dependency on bdsl, to make its own targ
	
	webhosts = {}
	clients = {}
	bdsl_websites = []
	
	for site in website_list:

		if site['webhost'] in webhosts:
			webhosts[site['webhost']].append (site['domain'])
		else:
			webhosts[site['webhost']] = [ site['domain'] ]

		if site['client'] in clients:
			clients[site['client']].append (site['domain'])
		else:
			clients[site['client']] = [ site['domain'] ]
		
		# print alias target
		# FIXME: print this later, after we have collected all of the domains? might not need to.
		print('{alias}: {domain}'.format ( alias = site['alias'], domain = site['domain']))
		print()
		
		# print dependencies
		# sowa.massart.edu: sowa/sowa.massart.edu/plugin/sowa.massart.edu-plugin//git sowa/sowa.massart.edu/theme/sowa.massart.edu-theme//git
		# sowa.massart.edu: sowa/sowa.massart.edu/plugin/sowa.massart.edu-plugin//git sowa/sowa.massart.edu/theme/sowa.massart.edu-theme//git
		dependencies = []
		# loop through all dependencies
		for dependency in site['dependencies']:
			dependency_target = ''
			# if site['function'] == 'git':
			if site['function'] == 'rsync' and dependency['path'] == BDSL_PLUGIN_PATH:
				site['remote_folder'] = '$(BDSL_PATH_LOCAL)'
			dependency_target = PART_SEPARATOR.join ( [ site['remote_host'], site['remote_folder'], dependency['type'], dependency['path'], SUBDOMAIN_SEPARATOR.join(site['subdomains']), site['function'] ] )
#				dependency_target = PART_SEPARATOR.join ( [ site['remote_host'],  '$(LOCAL_PATH_PREFIX)/' + site['remote_folder'], dependency['type'], dependency['path'], SUBDOMAIN_SEPARATOR.join(site['subdomains']), site['function'] ] )
		
			dependencies.append ( dependency_target )
				
			if dependency['path'] == BDSL_PLUGIN_PATH:
				if site['function'] == 'git':
					bdsl_websites.append ( dependency_target )
				if site['function'] == 'rsync':
					pass
					

		print('{domain}: {target}'.format ( domain = site['domain'], target = DEPENDENCY_SEPARATOR.join ( dependencies ) ))
		print()
	
	# print('webhosts:',webhosts)
	for host in webhosts:
		print('{webhost}: {list}'.format( webhost = host, list = SPACE.join(webhosts[host])))
		print()
	
	# print('clients:',clients)
	for client in clients:
		print('{cli}: {list}'.format( cli = client, list = SPACE.join(clients[client])))
		print()
	
	# print('bdsl_websites:',bdsl_websites)
	# FIXME: this passes the website names. It needs to pass the proper rule to only update the plugin
	print ('bdsl: {bdsl_websites}'.format( bdsl_websites = SPACE.join(bdsl_websites)))
	print()
	
	# does everything for every client
	print('all: {clients}'.format(clients = SPACE.join(clients.keys())))
	print()
	
websites = [ 
# sowa.massart.edu
{
	'domain': 'sowa.massart.edu',
	'remote_host': 'sowa',
	'remote_folder': 'sowa.massart.edu',
	'subdomains': [],
	'function': 'git',
	'dependencies': [ { 'type': 'plugin','path': 'sowa.massart.edu-plugin',}, { 'type': 'theme', 'path': 'sowa.massart.edu-theme',} ],
	'alias': 'sowa',
	'webhost': 'dreamhost',
	'client': 'sowa',
},
# ane.massart.edu
{
	'domain': 'ane.massart.edu',
	'remote_host': 'ane',
	'remote_folder': 'ane.massart.edu',
	'subdomains': [],
	'function': 'git',
	'dependencies': [ { 'type': 'plugin','path': 'ane-plugin',}, { 'type': 'theme', 'path': 'ane-theme',} ],
	'alias': 'ane',
	'webhost': 'dreamhost',
	'client': 'pce',
},
# pce.massart.edu
{
	'domain': 'pce.massart.edu',
	'remote_host': 'pce-prod',
	'remote_folder': 'pce.test',
	'subdomains': [],
	'function': 'rsync',
	'dependencies': [ { 'type': 'plugin','path': 'pce-plugin',}, { 'type': 'theme', 'path': 'pce-theme',}, BDSL_PLUGIN ],
	'alias': 'pce',
	'webhost': 'flywheel',
	'client': 'pce',
},
# 826boston.org
{
	'domain': '826boston.org',
	'remote_host': '826-prod',
	'remote_folder': '826boston.test',
	'subdomains': [],
	'function': 'rsync',
	'dependencies': [ { 'type': 'theme', 'path': 'yetti',}, BDSL_PLUGIN ],
	'alias': '826',
	'webhost': 'flywheel',
	'client': '826b',
},
# lifetimearts.org
{
	'domain': 'lifetimearts.org',
	'remote_host': LTA_BLUEHOST,
	'remote_folder': 'lifetimearts.org',
	'subdomains': ['dev','staging',],
	'function': 'git',
	'dependencies': [ { 'type': 'plugin','path': 'lifetime-arts-plugin',}, { 'type': 'theme', 'path': 'lifetime-arts-theme',}, BDSL_PLUGIN ],
	'alias': 'la',
	'webhost': 'bluehost',
	'client': 'lta',
},
# baizmandesign.com
{
	'domain': 'baizmandesign.com',
	'remote_host': 'bd',
	'remote_folder': 'baizmandesign.com',
	'subdomains': ['dev','staging',],
	'function': 'git',
	'dependencies': [ { 'type': 'plugin','path': 'baizmandesign.com-plugin',}, { 'type': 'theme', 'path': 'baizmandesign.com-theme',}, BDSL_PLUGIN ],
	'alias': 'bd',
	'webhost': 'dreamhost',
	'client': 'bzmn',
},
# saulbaizman.com
{
	'domain': 'saulbaizman.com',
	'remote_host': 'b',
	'remote_folder': 'saulbaizman.com',
	'subdomains': ['dev','staging',],
	'function': 'git',
	'dependencies': [ { 'type': 'plugin','path': 'saulbaizman.com-plugin',}, { 'type': 'theme', 'path': 'saulbaizman.com-theme',}, BDSL_PLUGIN ],
	'alias': 'sb',
	'webhost': 'dreamhost',
	'client': 'bzmn',
},
# creativeagingportal.org
{
	'domain': 'creativeagingportal.org',
	'remote_host': LTA_DREAMHOST,
	'remote_folder': 'creativeagingportal.org',
	'subdomains': ['dev','staging',],
	'function': 'git',
	'dependencies': [ { 'type': 'plugin','path': 'creative-aging-portal-plugin',}, { 'type': 'theme', 'path': 'creative-aging-portal-theme',}, BDSL_PLUGIN ],
	'alias': 'cap',
	'webhost': 'dreamhost',
	'client': 'lta',
},
# creativeagingresource.org
{
	'domain': 'creativeagingresource.org',
	'remote_host': LTA_DREAMHOST,
	'remote_folder': 'creativeagingresource.org',
	'subdomains': ['dev','staging',],
	'function': 'git',
	'dependencies': [ { 'type': 'plugin','path': 'car-plugin',}, { 'type': 'theme', 'path': 'car-theme',}, BDSL_PLUGIN ],
	'alias': 'car',
	'webhost': 'dreamhost',
	'client': 'lta',
},
# beagefriendly.org
{
	'domain': 'beagefriendly.org',
	'remote_host': LTA_DREAMHOST,
	'remote_folder': 'beagefriendly.org',
	'subdomains': ['dev','staging',],
	'function': 'git',
	'dependencies': [ { 'type': 'plugin','path': 'baf-plugin',}, { 'type': 'theme', 'path': 'dhyana',}, BDSL_PLUGIN ],
	'alias': 'baf',
	'webhost': 'dreamhost',
	'client': 'lta',
},
# nyccreativeaginginitiative.org
{
	'domain': 'nyccreativeaginginitiative.org',
	'remote_host': LTA_DREAMHOST,
	'remote_folder': 'nyccreativeaginginitiative.org',
	'subdomains': ['dev','staging',],
	'function': 'git',
	'dependencies': [ { 'type': 'plugin','path': 'nyccai-plugin',}, { 'type': 'theme', 'path': 'nyccai',}, BDSL_PLUGIN ],
	'alias': 'nyccai',
	'webhost': 'dreamhost',
	'client': 'lta',
},
# creativeagingtoolkit.org
{
	'domain': 'creativeagingtoolkit.org',
	'remote_host': LTA_BLUEHOST,
	'remote_folder': 'creativeagingtoolkit.org',
	'subdomains': ['dev','staging',],
	'function': 'git',
	'dependencies': [ { 'type': 'theme', 'path': 'creativeagingtoolkit-sunset',}, BDSL_PLUGIN ],
	'alias': 'nyccai',
	'webhost': 'bluehost',
	'client': 'lta',
},

]
# wouldn't it be easier to just put these in a tsv file? almost. the multi-dimensional array isn't so easy. if they all had the same suffix, that could be automatically parsed.

print_targets (websites)
