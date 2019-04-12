#!/usr/bin/env python

import sys, random, os, tempfile, string
from templite import Templite

def generate(argv):
  if len(argv) != 3:
    print 'Usage: pypy generate.py [seed] [output_file]'
    sys.exit()

  seed = argv[1]
  output_file = argv[2]

  random.seed(seed)

  description = ''
  with open(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'description.txt'), 'r') as desc_file:
    description = desc_file.read().encode('string_escape').replace('\"', '\\\"')

  padding0 = random.randint(0, 2**26)
  padding1 = random.randint(0, 2**26)

  template = open(os.path.join(os.path.dirname(os.path.realpath(__file__)), '05_angr_symbolic_memory.c.templite'), 'r').read()
  c_code = Templite(template).render(description=description, padding0=padding0, padding1=padding1)

  with tempfile.NamedTemporaryFile(delete=False, suffix='.c') as temp:
    temp.write(c_code)
    temp.seek(0)
    os.system('gcc -m32 -o ' + output_file + ' ' + temp.name)

if __name__ == '__main__':
  generate(sys.argv)
