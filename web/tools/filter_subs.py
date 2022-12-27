#!/usr/bin/env python3
# Written by Deep Dive Team.

import validators
import sys

def ValidateSubdomain(domain):
    domain = validators.domain(domain)
    return domain


try:
    for line in sys.stdin:
        subdomain = line.strip()
        if ValidateSubdomain(subdomain):
            print(subdomain)          
except:
    pass