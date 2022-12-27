#!/usr/bin/env python3
# Written by Deep Dive Team.

import requests
import json
import sys
import os
import time
import argparse

parser = argparse.ArgumentParser(description='Query CRT.SH for domains.')
parser.add_argument('-f', '--domain-file', dest='domainsFile', help='Input file containing domains to scan.')
parser.add_argument('-d', '--domain', dest='domain', help='Single/List of domains to scan. Examples: -d lala.com or -d "a.lala.com b.lala.com"')
parser.add_argument('-p', '--pipe-mode', dest='pipeMode', action='store_true', help='Receive domains to scan from pipe. Exmple: cat tld.txt | crt.sh -p.')
parser.add_argument('-i', '--interval', dest='interval', default=1, help='Time interval between scans (default 1 second)')
parser.add_argument('-r', '--remove-non-tld', dest='removeNonTLD', action='store_true', help='Do not return NON searched Top Level Domains.')
parser.add_argument('--debug', dest='debug', action='store_true', help='Debug output.')
args = parser.parse_args()

# Query the crt.sh serice:
####
def queryCRTSH(domain):
    resDomains = {}
    base_url = "https://crt.sh/?output=json&q={}"
    url = base_url.format(domain)
    ua = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1'
    req = requests.get(url, headers={'User-Agent': ua})
    if req.ok:
        try:
            content = req.content.decode('utf-8')
            data = json.loads(content)
            for d in data:
                if ((not args.removeNonTLD) or (d['common_name'].endswith(domain))):
                    resDomains[d['common_name']] = d['common_name']
                for nv in d['name_value'].split('\n'):
                    if ((not args.removeNonTLD) or (nv.endswith(domain))):
                        resDomains[nv] = nv
        except ValueError:
            data = json.loads('[{}]'.format(content.replace('}{', '},{')))
            print(data)
        except Exception as err:
            print('Error retrieving information.')
    return resDomains

# Main
####
if __name__ == '__main__':
    allDomains = {}
    scanDomains = []

    if (args.domain):
        scanDomains = args.domain.split(' ')
    elif not args.pipeMode:
        if not (args.domainsFile):
            print('ERROR: Please provide domain or domains file with -d, --domain-file or -f, --domain-file.')
            exit(1)
        else:
            if not (os.path.isfile(args.domainsFile)):
                print('ERROR: Can\'t open Domains File.')
                exit(1)
            else:
                f = open(args.domainsFile, 'rt')
                l = f.readline()
                while (l):
                    if (args.debug):
                        print('Adding ' + l.strip() + ' to scan.')
                    scanDomains.append(l.strip())
                    l = f.readline()
                f.close()
    if (not args.pipeMode and len(scanDomains) == 0):
        print('ERROR: No domains to scan, is the file empty?.')
        exit(1)

    if not (args.pipeMode):
        for scanDomain in scanDomains:
            resDomains = queryCRTSH(scanDomain)
            for d in resDomains:
                print(resDomains[d])
        allDomains.update(resDomains)
        time.sleep(float(args.interval))  
    else:
        if (args.pipeMode):
            for line in sys.stdin:
                scanDomain = line.strip()
                resDomains = queryCRTSH(scanDomain)
                for d in resDomains:
                    print(resDomains[d])
            allDomains.update(resDomains)
            time.sleep(float(args.interval))
           