#!/usr/bin/env python3

import requests
import json
import sys
import argparse
import time


parser = argparse.ArgumentParser(description='Sonar Subdomain Enumeration Tool')
parser.add_argument('-d', '--domain', dest='domain', help='TLD Domain to query')
parser.add_argument('-f', '--file', dest='filename', help='TLD Domains file')
parser.add_argument('-o', '--output', dest='output', help='Save results to CSV file', required=False)
parser.add_argument('-p', '--pipe', dest='pipe', help='get domains from pipe', required=False, action='store_true')


args = parser.parse_args()

def querySonar(domain):
    base_url = "https://sonar.omnisint.io/subdomains/{}"
    url = base_url.format(domain)
    ua = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1'
    req = requests.get(url, headers={'User-Agent': ua})
    if req.ok:
        try:
            content = req.content.decode('utf-8')
            data = json.loads(content)
            if args.output:
                f = open(args.output, 'a')
                for d in data:
                    print(d)
                    f.write(d + '\n')
                f.close()
            else:
                for d in data:
                    print(d)
        except Exception as err:
            print('Error retrieving information.')

def main():
    if args.domain:
        querySonar(args.domain)
    if args.filename:
        try:
            with open(args.filename, 'r') as f:
                for line in f:
                    line = line.strip()
                    querySonar(line)
                    time.sleep(5)
        except:
                print("An exception occurred")
    if (args.pipe):
        try:
            for line in sys.stdin:
                line = line.strip()
                querySonar(line)
                time.sleep(1)
        except:
                print("An exception occurred")


if __name__ == '__main__':
    main()

