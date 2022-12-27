#!/usr/bin/env python3

import sys

TLD_DOMAIN = sys.argv[1]

try:
    for line in sys.stdin:
        subdomain = line.strip()
        if subdomain.endswith(TLD_DOMAIN.strip()):
            print(subdomain.strip())
       
except:
    pass