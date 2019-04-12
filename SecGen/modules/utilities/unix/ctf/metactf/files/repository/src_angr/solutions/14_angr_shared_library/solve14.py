# The shared library has the function validate, which takes a string and returns
# either true (1) or false (0). The binary calls this function. If it returns
# true, the program prints "Good Job." otherwise, it prints "Try again."

import angr
import claripy
import sys

def main(argv):
  path_to_binary = argv[1]

  # The shared library is compiled with position-independent code. You will need
  # to specify the base address. All addresses in the shared library will be
  # base + offset, where offset is their address in the file.
  # (!)
  base = 0x4000000
  project = angr.Project(path_to_binary, load_options={ 
    'main_opts' : { 
      'custom_base_addr' : base 
    } 
  })

  # Initialize any needed values here; you will need at least one to pass to
  # the validate function.
  buffer_pointer = claripy.BVV(0x3000000, 32)

  # Begin the state at the beginning of the validate function, as if it was
  # called by the program. Determine the parameters needed to call validate and
  # replace 'parameters...' with bitvectors holding the values you wish to pass.
  # Recall that 'claripy.BVV(value, size_in_bits)' constructs a bitvector 
  # initialized to a single value.
  # Remember to add the base value you specified at the beginning to the
  # function address!
  # Hint: int validate(char* buffer, int length) { ...
  # Another hint: the password is 8 bytes long.
  # (!)
  validate_function_address = base + 0x6d7
  initial_state = project.factory.call_state(validate_function_address, buffer_pointer, claripy.BVV(8, 32))

  # You will need to add code to inject a symbolic value into the program. Also, 
  # at the end of the function, constrain eax to equal true (value of 1) just
  # before the function returns. There are multiple ways to do this:
  # 1. Use a hook.
  # 2. Search for the address just before the function returns and then
  #    constrain eax (this may require putting code elsewhere)
  password = claripy.BVS('password', 8*8)
  initial_state.memory.store(buffer_pointer, password)

  simulation = project.factory.simgr(initial_state)

  success_address = base + 0x783
  simulation.explore(find=success_address)

  if simulation.found:
    solution_state = simulation.found[0]

    solution_state.add_constraints(solution_state.regs.eax != 0)
  
    # Determine where the program places the return value, and constrain it so
    # that it is true. Then, solve for the solution and print it.
    # (!)
    solution = solution_state.se.eval(password,cast_to=str)
    print solution
  else:
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
