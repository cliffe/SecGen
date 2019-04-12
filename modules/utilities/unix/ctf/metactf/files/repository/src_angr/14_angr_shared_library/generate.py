#!/usr/bin/env python

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

  template = open(os.path.join(os.path.dirname(os.path.realpath(__file__)), '14_angr_shared_library_so.c.templite'), 'r').read()
  c_code = Templite(template).render(description=description)

  with tempfile.NamedTemporaryFile(delete=False, suffix='.c') as temp:
    temp.write(c_code)
    temp.seek(0)
    os.system('gcc -I' + os.path.dirname(os.path.realpath(__file__))  + ' -fno-stack-protector -fpic -m32 -c -o 14_angr_shared_library.o ' + temp.name)
    os.system('gcc -shared -m32 -o ' + os.path.join('/'.join(output_file.split('/')[0:-1]), 'lib' + output_file.split('/')[-1] + '.so') + ' 14_angr_shared_library.o')
    os.system('rm 14_angr_shared_library.o')
    os.system('chmod -x ' + os.path.join('/'.join(output_file.split('/')[0:-1]), 'lib' + output_file.split('/')[-1] + '.so'))

  template = open(os.path.join(os.path.dirname(os.path.realpath(__file__)), '14_angr_shared_library.c.templite'), 'r').read()
  c_code = Templite(template).render()

  with tempfile.NamedTemporaryFile(delete=False, suffix='.c') as temp:
    temp.write(c_code)
    temp.seek(0)
    os.system('gcc -m32 -I . -L ' + '/'.join(output_file.split('/')[0:-1]) + ' -o ' + output_file + ' ' + temp.name + ' -l' + output_file.split('/')[-1])

if __name__ == '__main__':
  generate(sys.argv)
