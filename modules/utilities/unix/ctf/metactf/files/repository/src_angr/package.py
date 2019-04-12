#!/usr/bin/env python
import datetime, os, sys, shutil

def level_generate_module(level_name):
  return __import__(level_name + '.generate')

def package_level(level_name, output_base_directory, num_binaries, user, salt, extra_files):
  seed = level_name + user + salt
  generate_module = level_generate_module(level_name)
  output_directory = output_base_directory
  binary_file_output_prefix = os.path.join(output_directory, level_name)
  suffix_format_str = '{:0' + str(len(str(num_binaries - 1))) + '}' if (num_binaries - 1 > 0) else ''

  if not os.path.exists(output_directory):
    os.makedirs(output_directory)

  for i in xrange(num_binaries):
    suffix = suffix_format_str.format(i)
    binary_file_output = binary_file_output_prefix + suffix
    generate_module.generate.generate([None, seed, binary_file_output])

  for extra_file in extra_files:
    extra_file_abs = os.path.join('.', level_name, extra_file)
    extra_file_target = os.path.join(output_base_directory, extra_file)
    shutil.copyfile(extra_file_abs, extra_file_target)
  name_candidates = user.split('/')
  if len(name_candidates) >= 2:
    name = name_candidates[-2]
  else:
    name = name_candidates[-1]
  print('Compiled %s for user %s.' % (level_name, name))

def package_all(root_folder):
  num_binaries = 1
  year = str(datetime.datetime.now().year)
  package_level('00_angr_find', root_folder, num_binaries, root_folder, year, ['scaffold00.py'])
  package_level('01_angr_avoid', root_folder, num_binaries, root_folder, year, ['scaffold01.py'])
  package_level('02_angr_find_condition', root_folder, num_binaries, root_folder, year, ['scaffold02.py'])
  package_level('03_angr_symbolic_registers', root_folder, num_binaries, root_folder, year, ['scaffold03.py'])
  package_level('04_angr_symbolic_stack', root_folder, num_binaries, root_folder, year, ['scaffold04.py'])
  package_level('05_angr_symbolic_memory', root_folder, num_binaries, root_folder, year, ['scaffold05.py'])
  package_level('06_angr_symbolic_dynamic_memory', root_folder, num_binaries, root_folder, year, ['scaffold06.py'])
  package_level('07_angr_symbolic_file', root_folder, num_binaries, root_folder, year, ['scaffold07.py'])
  package_level('08_angr_constraints', root_folder, num_binaries, root_folder, year, ['scaffold08.py'])
  package_level('09_angr_hooks', root_folder, num_binaries, root_folder, year, ['scaffold09.py'])
  package_level('10_angr_simprocedures', root_folder, num_binaries, root_folder, year, ['scaffold10.py'])
  package_level('11_angr_sim_scanf', root_folder, num_binaries, root_folder, year, ['scaffold11.py'])
  package_level('12_angr_veritesting', root_folder, num_binaries, root_folder, year, ['scaffold12.py'])
  package_level('13_angr_static_binary', root_folder, num_binaries, root_folder, year, ['scaffold13.py'])
  package_level('14_angr_shared_library', root_folder, num_binaries, root_folder, year, ['scaffold14.py'])
  package_level('15_angr_arbitrary_read', root_folder, num_binaries, root_folder, year, ['scaffold15.py'])
  package_level('16_angr_arbitrary_write', root_folder, num_binaries, root_folder, year, ['scaffold16.py'])
  package_level('17_angr_arbitrary_jump', root_folder, num_binaries, root_folder, year, ['scaffold17.py'])

if __name__ == '__main__':
  if len(sys.argv) != 2:
    print('Usage: python package.py [base_directory]')
    sys.exit()

  if not os.path.exists(sys.argv[1]):
    os.makedirs(sys.argv[1])
  package_all(sys.argv[1])
