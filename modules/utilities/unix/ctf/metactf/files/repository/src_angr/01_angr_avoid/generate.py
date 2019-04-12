#!/usr/bin/env pypy
import sys, random, os, tempfile
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

  random_list = [random.choice([True, False]) for _ in xrange(64)]

  template = open(os.path.join(os.path.dirname(os.path.realpath(__file__)), '01_angr_avoid.c.templite'), 'r').read()
  c_code = Templite(template).render(description=description, random_list=random_list)

  with tempfile.NamedTemporaryFile(delete=False, suffix='.c') as temp:
    temp.write(c_code)
    temp.seek(0)
    os.system('gcc -m32 -o ' + output_file + ' ' + temp.name)

if __name__ == '__main__':
  generate(sys.argv)
