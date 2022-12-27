#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import requests
import argparse
import sys

parser = argparse.ArgumentParser()
parser.add_argument('-d', '--domain', dest='domain', help="Target domain.")
parser.add_argument('-p', '--pipe-mode', dest='pipeMode', action='store_true', help='Receive domains to scan from pipe')
args = parser.parse_args()


def clear_url(target):
	return re.sub('.*www\.','',target,1).split('/')[0].strip()


def EnumDomain(domain):
	try:
		subdomains = []
		target = clear_url(domain)
		
		req = requests.get("https://crt.sh/?q=%.{d}&output=json".format(d=target))

		if req.status_code != 200:
			exit(1)

		for (key,value) in enumerate(req.json()):
			subdomains.append(value['name_value'])

		subdomains = sorted(set(subdomains))
		for subdomain in subdomains:
			print("{s}".format(s=subdomain))
	except:
		pass

def main():
	if (args.pipeMode):
		for line in sys.stdin:
			EnumDomain(line.strip())
	elif (args.domain):
		EnumDomain(args.domain)

main()
	
