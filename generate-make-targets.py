#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# TODO: load data from external TSV file. Adding new sites is easier to update in a text file.
# TODO: automatically surmise asset type from asset name.

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
	
	print('# note: the contents of this makefile must be included in the parent Makefile for deploy-make')
	print()

	# sort list by domain name
	# https://stackoverflow.com/questions/72899/how-do-i-sort-a-list-of-dictionaries-by-a-value-of-the-dictionary
	website_list = sorted(website_list, key=lambda d: d['domain'])

	webhosts = {}
	clients = {}
	bdsl_websites = []
	subdomains = {}
	prod_domains = []
	
	for site in website_list:

		if site['webhost'] in webhosts:
			webhosts[site['webhost']].append (site['domain'])
		else:
			webhosts[site['webhost']] = [ site['domain'] ]

		if site['client'] in clients:
			clients[site['client']].append (site['domain'])
		else:
			clients[site['client']] = [ site['domain'] ]
		
		for sub in site['subdomains']:
			if sub in subdomains:
				subdomains[sub].append ( sub + '.' + site['domain'] )
			else:
				subdomains[sub] = [ sub + '.' + site['domain']]
		
		prod_domains.append ( site['domain'] )
		
		all_domains = [ site['domain'] ]
		all_domains += [ sub+'.'+site['domain'] for sub in site['subdomains']]

		# print alias target
		print('{alias}: {domains}'.format ( alias = site['alias'], domains = DEPENDENCY_SEPARATOR.join ( all_domains ) ))
		print()
		
		# print dependencies
		# sowa.massart.edu: sowa/sowa.massart.edu/plugin/sowa.massart.edu-plugin/git sowa/sowa.massart.edu/theme/sowa.massart.edu-theme/git
		# loop through all dependencies
		# print('all_domains:',all_domains)
		# exit()
		for domain in all_domains:
			dependency_target = ''
			dependencies = [ ]
			for dependency in site['dependencies']:
				# over-ride the subfolder value if we're doing rsync for bdsl
				if site['function'] == 'rsync' and dependency['path'] == BDSL_PLUGIN_PATH:
					site['subfolder'] = '$(BDSL_PATH_LOCAL)'
				
				dependency_target = PART_SEPARATOR.join ( [ site['remote_host'], domain, dependency['type'], dependency['path'], site['function'] ] )
					
				dependencies.append ( dependency_target )
					
				if dependency['path'] == BDSL_PLUGIN_PATH:
					bdsl_websites.append ( dependency_target )
						
	
			print('{domain}: {target}'.format ( domain = domain, target = DEPENDENCY_SEPARATOR.join ( dependencies ) ))
			print()
	
	print('# webhost targets')
	for host in webhosts:
		print('{webhost}: {list}'.format( webhost = host, list = SPACE.join(webhosts[host])))
		print()
	
	print('# client targets')
	for client in clients:
		print('{cli}: {list}'.format( cli = client, list = SPACE.join(clients[client])))
		print()
	
	print('# bdsl plugin targets')
	print ('bdsl: {bdsl_websites}'.format( bdsl_websites = SPACE.join(bdsl_websites)))
	print()
	
	# FIXME: need to pass other values, not just domain
	# for subdomain in subdomains:
	# 	print('{subdomain}: {domains}'.format( subdomain = subdomain, domains = SPACE.join(subdomains[subdomain])))
	# 	print()

	# FIXME: this will update all subdomains
	#print ('prod: {prod_domains}'.format( prod_domains = SPACE.join(prod_domains)))
	#print()
	
	print('# every site for every client')
	# does everything for every client
	print('all: {clients}'.format(clients = SPACE.join(clients.keys())))
	print()
	
websites = [ 
# sowa.massart.edu
{
	'domain': 'sowa.massart.edu',
	'remote_host': 'sowa',
	'subfolder': 'sowa.massart.edu',
	'subdomains': [], # comma-separated list of subdomain names, without the domain portion
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
	'subfolder': 'ane.massart.edu',
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
	'subfolder': 'pce.test',
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
	'subfolder': '826boston.test',
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
	'subfolder': 'lifetimearts.org',
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
	'subfolder': 'baizmandesign.com',
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
	'subfolder': 'saulbaizman.com',
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
	'subfolder': 'creativeagingportal.org',
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
	'subfolder': 'creativeagingresource.org',
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
	'subfolder': 'beagefriendly.org',
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
	'subfolder': 'nyccreativeaginginitiative.org',
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
	'subfolder': 'creativeagingtoolkit.org',
	'subdomains': ['staging',],
	'function': 'git',
	'dependencies': [ { 'type': 'theme', 'path': 'creativeagingtoolkit-sunset',}, BDSL_PLUGIN ],
	'alias': 'cat',
	'webhost': 'bluehost',
	'client': 'lta',
},
# saoriworcester.com
{
	'domain': 'saoriworcester.com',
	'remote_host': 'saori',
	'subfolder': 'saoriworcester.com',
	'subdomains': ['dev',],
	'function': 'git',
	'dependencies': [ { 'type': 'theme', 'path': 'saori-worcester-theme',}, ],
	'alias': 'saori',
	'webhost': 'dreamhost',
	'client': 'saor',
},

]

print_targets (websites)
