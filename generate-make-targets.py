#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# TODO: automatically surmise asset type from asset name. Revise function in Makefile.
# TODO: check for duplicate target names and abort. (It's permitted in make, but will create problems during execution.) 

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

def print_targets ( website_list ):
	
	print('# note: the contents of this makefile must be included in the parent Makefile for deploy-make')
	print()

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
		print('{alias}: {domains}'.format ( alias = site['alias'], domains = DEPENDENCY_SEPARATOR.join ( all_domains ) ))
		print()
		
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
				
				if dependency_type == 'UNKNOWN':
					print()
					print('# Warning: "{dependency}" is neither a plugin nor theme. Aborting.'.format ( dependency = dependency ) )
					print()
					sys.exit(1)
				if site['function'] == 'rsync':
					dependency_target = PART_SEPARATOR.join ( [ site['remote_host'], site['subfolder'], dependency_type, dependency, site['function'] ] )
				#if site['function'] == 'git':
				else:
					dependency_target = PART_SEPARATOR.join ( [ site['remote_host'], domain, dependency_type, dependency, site['function'] ] )
					
				dependencies.append ( dependency_target )
					
				if dependency == BDSL_PLUGIN_PATH:
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
	
	print('# targets for all subdomains')
	for subdomain in subdomains:
		print('# target for {subdomain}'.format( subdomain = subdomain ))
		print('{subdomain}: {domains}'.format( subdomain = subdomain, domains = SPACE.join(subdomains[subdomain] )))
		print()

	print('# all production domains')
	print ('prod: {prod_domains}'.format( prod_domains = SPACE.join(prod_domains)))
	print()
	
	print('# every site for every client')
	# does everything for every client
	print('all: {clients}'.format(clients = SPACE.join(clients.keys())))
	print()

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
