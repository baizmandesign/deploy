#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# TODO: automatically surmise asset type from asset name. Revise function in Makefile.

'''
This program prints a list of make targets.
'''

import csv, os, sys

TSV_DELIMITER='\t'
PART_SEPARATOR = '/'
LIST_SEPARATOR = ','
SPACE = ' '
DEPENDENCY_SEPARATOR = SPACE
BDSL_PLUGIN_PATH = 'baizman-design-standard-library'
BDSL_PATH_LOCAL = 'bd.test'
LTA_DREAMHOST = 'cap' # defined in ~/.ssh/config
LTA_BLUEHOST = 'lta' # defined in ~/.ssh/config
FIELD_COUNT = 9 # number of fields in tsv file, for data validation

def usage ( ):
	"""print a usage statement."""
	print()
	print('usage: {self} <tsv_file>'.format ( self = os.path.basename( sys.argv[0] ) ) )
	print()
	sys.exit(0)

def duplicate_error ( duplicate ):
	"""print duplicate error and abort."""
	print('"{duplicate}" is a duplicate target name. Aborting...'.format(duplicate = duplicate))
	print()
	sys.exit(1)

def print_target ( target, prerequisites ):
	"""print a single target."""
	print('.PHONY: {target}'.format(target = target))
	print('{target}: {prerequisites}'.format(target = target, prerequisites = prerequisites))
	print()

def print_targets ( website_list ):
	"""print all asset targets."""
	print('# note: the contents of this makefile must be included in the parent Makefile for deploy-make')
	print()
	
	# create a list of unique targets. this will help identify potential duplicates.
	unique_targets = []

	# sort list by domain name
	# https://stackoverflow.com/questions/72899/how-do-i-sort-a-list-of-dictionaries-by-a-value-of-the-dictionary
	website_list = sorted(website_list, key=lambda site: site['domain'])

	webhosts = {}
	clients = {}
	bdsl_websites = []
	subdomains = {}
	prod_domains = []
	
	for site in website_list:

		# create dictionary keyed by webhosts
		if site['webhost'] in webhosts:
			webhosts[site['webhost']].append (site['domain'])
		else:
			webhosts[site['webhost']] = [ site['domain'] ]

		# create dictionary keyed by clients
		if site['client'] in clients:
			clients[site['client']].append (site['domain'])
		else:
			clients[site['client']] = [ site['domain'] ]
		
		# strip leading and trailing whitespace from subdomains
		website_subdomains = []
		if site['subdomains'] != '':
			 website_subdomains = [ website_subdomain.strip() for website_subdomain in site['subdomains'].split(LIST_SEPARATOR) ]
		
		# create a dictionary keyed by subdomain
		for sub in website_subdomains:
			if sub in subdomains:
				subdomains[sub].append ( sub + '.' + site['domain'] )
			else:
				subdomains[sub] = [ sub + '.' + site['domain']]
		
		prod_domains.append ( site['domain'] )
		
		# add subdomains to the list of domains
		all_domains = [ site['domain'] ]
		all_domains += [ sub+'.'+site['domain'] for sub in website_subdomains ]

		# print alias target
		print_target (site['alias'], DEPENDENCY_SEPARATOR.join ( all_domains ))
		
		if site['alias'] not in unique_targets:
			unique_targets.append ( site['alias'] )
		else:
			duplicate_error( site['alias'] )
		
		# loop through all dependencies of all domains
		for domain in all_domains:
			dependency_target = ''
			dependencies = [ ]
			for dependency in site['dependencies'].split(LIST_SEPARATOR):
				# strip leading and trailing whitespace
				dependency = dependency.strip()
				# over-ride the subfolder value if we're doing rsync for bdsl
				if site['function'] == 'rsync' and dependency == BDSL_PLUGIN_PATH:
					site['subfolder'] = BDSL_PATH_LOCAL
				dependency_type = 'UNKNOWN'
				if dependency.endswith('-theme'):
					dependency_type = 'theme'
				if dependency.endswith('-plugin') or dependency == BDSL_PLUGIN_PATH:
					dependency_type = 'plugin'
				
				# force using 'wp' function for the bdsl plugin, which can now be updated via the wp dashboard (and will no longer contain the git repo and can no longer use the 'git' function)
				previous_site_function = site['function']
				if dependency == BDSL_PLUGIN_PATH:
					site['function'] = 'wp'
				
				if dependency_type == 'UNKNOWN':
					print()
					print('# Warning: "{dependency}" is neither a plugin nor theme. Aborting.'.format ( dependency = dependency ) )
					print()
					sys.exit(1)
				if site['function'] == 'rsync':
					dependency_target = PART_SEPARATOR.join ( [ site['remote_host'], site['subfolder'], dependency_type, dependency, site['function'] ] )
				# 'git' or 'wp'
				else:
					dependency_target = PART_SEPARATOR.join ( [ site['remote_host'], domain, dependency_type, dependency, site['function'] ] )
					
				dependencies.append ( dependency_target )
					
				if dependency == BDSL_PLUGIN_PATH:
					bdsl_websites.append ( dependency_target )
						
				# reset site function to previous value
				site['function'] = previous_site_function

			print_target (domain, DEPENDENCY_SEPARATOR.join ( dependencies ))
			if domain not in unique_targets:
				unique_targets.append ( domain )
			else:
				duplicate_error( domain )
					
	
	print('# webhost targets')
	for host in webhosts:
		print_target (host, SPACE.join(webhosts[host]))
		if host not in unique_targets:
			unique_targets.append ( host )
		else:
			duplicate_error( host )

	print('# client targets')
	for client in clients:
		print_target (client, SPACE.join(clients[client]))
	
	print('# bdsl plugin targets')
	print_target ('bdsl', SPACE.join(bdsl_websites))
	if 'bdsl' not in unique_targets:
		unique_targets.append ( 'bdsl' )
	else:
		duplicate_error( 'bdsl' )

	print('# targets for all subdomains')
	for subdomain in subdomains:
		print('# target for {subdomain}'.format( subdomain = subdomain ))
		print_target (subdomain, SPACE.join(subdomains[subdomain]))
		if subdomain not in unique_targets:
			unique_targets.append ( subdomain )
		else:
			duplicate_error( subdomain )

	print('# all production domains')
	print_target ('prod', SPACE.join(prod_domains))
	if 'prod' not in unique_targets:
		unique_targets.append ( 'prod' )
	else:
		duplicate_error( 'prod' )

	print('# every site for every client')
	# does everything for every client
	print_target ('all', SPACE.join(clients.keys()))
	if 'all' not in unique_targets:
		unique_targets.append ( 'all' )
	else:
		duplicate_error( 'all' )

if __name__ == "__main__":

	if len(sys.argv) != 2:
		usage()
	
	FILENAME=sys.argv[1]
	
	if not os.path.exists(FILENAME):
		print()
		print('TSV file "{file}" does not exist. Exiting.'.format ( file = FILENAME ) )
		print()
		sys.exit(1)
	
	with open(FILENAME, 'r') as tsvfile:
		websites_tsv = csv.DictReader(tsvfile, delimiter=TSV_DELIMITER, quotechar='"')
		line_number = 0
		websites = []
		for line in websites_tsv:
			actual_field_count = len (line)
			if actual_field_count != FIELD_COUNT:
				print ("Line {line_number} contains {actual_field_count} fields and must have {field_count} fields.".format ( line_number = line_number, actual_field_count = actual_field_count, field_count = FIELD_COUNT ))
				sys.exit(1)
			#strip spaces from values
			line_stripped = { key: value.strip() for key, value in line.items() }		
			websites.append (line_stripped)
			line_number+=1
	
	print_targets (websites)
