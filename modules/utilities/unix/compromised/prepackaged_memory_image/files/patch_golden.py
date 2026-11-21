#!/usr/bin/env python3
"""Rewrite the per-build artefact tokens inside a pre-captured memory image.

The image is a fixed, atomically-captured RAM dump. Each build replaces the
tokens that were baked in at capture time (the "from" values, recorded in a
sidecar JSON) with this build's random values (the "to" values, passed as
--set name=value). Every token is a fixed-length hex string and its replacement
is the same length, so each occurrence is overwritten in place via mmap: no byte
moves, so every process structure, socket and string offset Volatility reads
stays exactly where it was.
"""
import argparse
import json
import mmap
import sys


def load_sidecar(path):
    with open(path) as f:
        data = json.load(f)
    return {k: v for k, v in data.items() if not k.startswith('_')}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--image', required=True, help='memory image to patch in place')
    ap.add_argument('--tokens', required=True, help='sidecar JSON of baked (from) values')
    ap.add_argument('--set', action='append', default=[], metavar='NAME=VALUE',
                    help='this build\'s value for a token (repeatable)')
    args = ap.parse_args()

    baked = load_sidecar(args.tokens)
    new = {}
    for pair in args.set:
        if '=' not in pair:
            sys.exit(f'ERROR: --set expects NAME=VALUE, got {pair!r}')
        name, val = pair.split('=', 1)
        new[name] = val

    # Build the from->to list, validating as we go.
    plan = []
    for name, newval in new.items():
        if name not in baked:
            sys.exit(f'ERROR: token {name!r} not in sidecar {args.tokens}')
        oldval = baked[name]
        if len(oldval) != len(newval):
            sys.exit(f'ERROR: {name}: baked len {len(oldval)} != new len {len(newval)} '
                     '(in-place patch needs equal lengths)')
        plan.append((name, oldval.encode(), newval.encode()))

    # No baked token may be a substring of another, or an in-place replace of the
    # shorter could corrupt the longer. Random hex makes this impossible; assert it.
    olds = [o for _n, o, _nw in plan]
    for i, a in enumerate(olds):
        for j, b in enumerate(olds):
            if i != j and a in b:
                sys.exit(f'ERROR: baked token {a!r} is a substring of {b!r}; '
                         'cannot patch safely')

    # Longest first, so a 12-char token can never land inside a 32-char run we have
    # not yet rewritten.
    plan.sort(key=lambda t: -len(t[1]))

    with open(args.image, 'r+b') as f:
        m = mmap.mmap(f.fileno(), 0)
        try:
            rc = 0
            for name, old, newb in plan:
                n = 0
                i = m.find(old)
                while i != -1:
                    m[i:i + len(newb)] = newb
                    n += 1
                    i = m.find(old, i + len(newb))
                if n == 0:
                    # The baked value is not in the image: the sidecar does not match
                    # this golden. Fail loudly rather than ship an unpatched token.
                    print(f'ERROR: baked token {name} ({old.decode()}) not found in image '
                          '-- stale sidecar?', file=sys.stderr)
                    rc = 1
                else:
                    print(f'  {name}: replaced {n} occurrence(s)')
            m.flush()
        finally:
            m.close()
    sys.exit(rc)


if __name__ == '__main__':
    main()
