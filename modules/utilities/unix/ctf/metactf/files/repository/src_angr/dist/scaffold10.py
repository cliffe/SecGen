# This challenge is similar to the previous one. It operates under the same
# premise that you will have to replace the check_equals_ function. In this 
# case, however, check_equals_ is called so many times that it wouldn't make 
# sense to hook where each one was called. Instead, use a SimProcedure to write
# your own check_equals_ implementation and then hook the check_equals_ symbol 
# to replace all calls to scanf with a call to your SimProcedure.
#
# You may be thinking: 
#   Why can't I just use hooks? The function is called many times, but if I hook
#   the address of the function itself (rather than the addresses where it is 
#   called), I can replace its behavior everywhere. Furthermore, I can get the
#   parameters by reading them off the stack (with memory.load(regs.esp + xx)),
#   and return a value by simply setting eax! Since I know the length of the 
#   function in bytes, I can return from the hook just before the 'ret'
#   instruction is called, which will allow the program to jump back to where it
#   was before it called my hook.
# If you thought that, then congratulations! You have just invented the idea of
# SimProcedures! Instead of doing all of that by hand, you can let the already-
# implemented SimProcedures do the boring work for you so that you can focus on
# writing a replacement function in a Pythonic way.
# As a bonus, SimProcedures allow you to specify custom calling conventions, but
# unfortunately it is not covered in this CTF.

import angr
import claripy
import sys

def main(argv):
  path_to_binary = argv[1]
  project = angr.Project(path_to_binary)

  initial_state = project.factory.entry_state()

  # Define a class that inherits angr.SimProcedure in order to take advantage
  # of Angr's SimProcedures.
  class ReplacementCheckEquals(angr.SimProcedure):
    # A SimProcedure replaces a function in the binary with a simulated one
    # written in Python. Other than it being written in Python, the function
    # acts largely the same as any function written in C. Any parameter after
    # 'self' will be treated as a parameter to the function you are replacing.
    # The parameters will be bitvectors. Additionally, the Python can return in
    # the ususal Pythonic way. Angr will treat this in the same way it would
    # treat a native function in the binary returning. An example:
    #
    # int add_if_positive(int a, int b) {
    #   if (a >= 0 && b >= 0) return a + b;
    #   else return 0;
    # }
    #
    # could be simulated with...
    #
    # class ReplacementAddIfPositive(angr.SimProcedure):
    #   def run(self, a, b):
    #     if a >= 0 and b >=0:
    #       return a + b
    #     else:
    #       return 0
    #
    # Finish the parameters to the check_equals_ function. Reminder:
    # int check_equals_AABBCCDDEEFFGGHH(char* to_check, int length) { ...
    # (!)
    def run(self, to_check, ...???):
      # We can almost copy and paste the solution from the previous challenge.
      # Hint: Don't look up the address! It's passed as a parameter.
      # (!)
      user_input_buffer_address = ???
      user_input_buffer_length = ???

      # Note the use of self.state to find the state of the system in a 
      # SimProcedure.
      user_input_string = self.state.memory.load(
        user_input_buffer_address,
        user_input_buffer_length
      )

      check_against_string = ???
      
      # Finally, instead of setting eax, we can use a Pythonic return statement
      # to return the output of this function. 
      # Hint: Look at the previous solution.
      return claripy.If(???, ???, ???)


  # Hook the check_equals symbol. Angr automatically looks up the address 
  # associated with the symbol. Alternatively, you can use 'hook' instead
  # of 'hook_symbol' and specify the address of the function. To find the 
  # correct symbol, disassemble the binary.
  # (!)
  check_equals_symbol = ??? # :string
  project.hook_symbol(check_equals_symbol, ReplacementCheckEquals())

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

    solution = ???
    print solution
  else:
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
