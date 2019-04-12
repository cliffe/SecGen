# This level performs the following computations:
#
# 1. Get 16 bytes of user input and encrypt it.
# 2. Save the result of check_equals_AABBCCDDEEFFGGHH (or similar)
# 3. Get another 16 bytes from the user and encrypt it.
# 4. Check that it's equal to a predefined password.
#
# The ONLY part of this program that we have to worry about is #2. We will be
# replacing the call to check_equals_ with our own version, using a hook, since
# check_equals_ will run too slowly otherwise.

import angr
import claripy
import sys

def main(argv):
  path_to_binary = argv[1]
  project = angr.Project(path_to_binary)

  # Since Angr can handle the initial call to scanf, we can start from the
  # beginning.
  initial_state = project.factory.entry_state()

  # Hook the address of where check_equals_ is called.
  # (!)
  check_equals_called_address = ???

  # The length parameter in angr.Hook specifies how many bytes the execution
  # engine should skip after completing the hook. This will allow hooks to
  # replace certain instructions (or groups of instructions). Determine the
  # instructions involved in calling check_equals_, and then determine how many
  # bytes are used to represent them in memory. This will be the skip length.
  # (!)
  instruction_to_skip_length = ???
  @project.hook(check_equals_called_address, length=instruction_to_skip_length)
  def skip_check_equals_(state):
    # Determine the address where user input is stored. It is passed as a
    # parameter ot the check_equals_ function. Then, load the string. Reminder:
    # int check_equals_(char* to_check, int length) { ...
    user_input_buffer_address = ??? # :integer, probably hexadecimal
    user_input_buffer_length = ???
    user_input_string = state.memory.load(
      user_input_buffer_address, 
      user_input_buffer_length
    )
    
    # Determine the string this function is checking the user input against.
    # It's encoded in the name of this function; decompile the program to find
    # it.
    check_against_string = ??? # :string

    # gcc uses eax to store the return value, if it is an integer. We need to
    # set eax to 1 if check_against_string == user_input_string and 0 otherwise.
    # However, since we are describing an equation to be used by z3 (not to be
    # evaluated immediately), we cannot use Python if else syntax. Instead, we 
    # have to use claripy's built in function that deals with if statements.
    state.regs.eax = claripy.If(
      user_input_string == check_against_string, 
      claripy.BVV(1, 32), 
      claripy.BVV(0, 32)
    )

  simulation = project.factory.simgr(initial_state)

  def is_successful(state):
    stdout_output = state.posix.dumps(sys.stdout.fileno())
    return ???

  def should_abort(state):
    stdout_output = state.posix.dumps(sys.stdout.fileno())
    return ???

  simulation.explore(find=is_successful, avoid=should_abort)

  if simulation.found:
    solution_state = simulation.found[0]

    # Since we are allowing Angr to handle the input, retrieve it by printing
    # the contents of stdin. Use one of the early levels as a reference.
    solution = ???
    print solution
  else:
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
