#!/usr/bin/env python3

"""
Short script to encode password for use with CTFd v2.0.2+.
Requires Python3 and the following libraries:

pip install passlib passlib[bcrypt]
"""

import argparse
from passlib.hash import bcrypt_sha256


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("password", help="Password to encode to bcrypt sha256 2b variant")

args = parser.parse_args()
print("Generating password for use with CTFd v2.0.2+...\n")
hashed = bcrypt_sha256.encrypt(args.password)
print(hashed)
