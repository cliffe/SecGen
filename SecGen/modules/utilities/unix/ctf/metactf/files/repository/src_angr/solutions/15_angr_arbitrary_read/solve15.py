# Some of the source code for this challenge:
#
# #include <stdio.h>
# #include <stdlib.h>
# #include <string.h>
# #include <stdint.h>
# 
# // This will all be in .rodata
# char msg[] = "${ description }$";
# char* try_again = "Try again.";
# char* good_job = "Good Job.";
# uint32_t key;
# 
# void print_msg() {
#   printf("%s", msg);
# }
#
# uint32_t complex_function(uint32_t input) {
#   ...
# }
# 
# struct overflow_me {
#   char buffer[16];
#   char* to_print;
# }; 
# 
# int main(int argc, char* argv[]) {
#   struct overflow_me locals;
#   locals.to_print = try_again;
# 
#   print_msg();
# 
#   printf("Enter the password: ");
#   scanf("%u %20s", &key, locals.buffer);
#
#   key = complex_function(key);
# 
#   switch (key) {
#     case ?:
#       puts(try_again);
#       break;
#
#     ...
#
#     case ?:
#       puts(locals.to_print);
#       break;
#     
#     ...
#   }
# 
#   return 0;
# }

import angr
import claripy
import sys

def main(argv):
  path_to_binary = argv[1]
  project = angr.Project(path_to_binary)

  # You can either use a blank state or an entry state; just make sure to start
  # at the beginning of the program.
  # (!)
  initial_state = project.factory.entry_state()

  # Again, scanf needs to be replaced.
  class ReplacementScanf(angr.SimProcedure):
    # Hint: scanf("%u %20s")
    def run(self, format_string, param0, param1):
      # %u
      scanf0 = claripy.BVS('scanf0', 32)
      
      # %20s
      scanf1 = claripy.BVS('scanf1', 20*8)

      # The bitvector.chop(bits=n) function splits the bitvector into a Python
      # list containing the bitvector in segments of n bits each. In this case,
      # we are splitting them into segments of 8 bits (one byte.)
      for char in scanf1.chop(bits=8):
        # Ensure that each character in the string is printable. An interesting
        # experiment, once you have a working solution, would be to run the code
        # without constraining the characters to the printable range of ASCII.
        # Even though the solution will technically work without this, it's more
        # difficult to enter in a solution that contains character you can't
        # copy, paste, or type into your terminal or the web form that checks 
        # your solution.
        # (!)
        self.state.add_constraints(char >= 'A', char <= 'Z')

      # Warning: Endianness only applies to integers. If you store a string in
      # memory and treat it as a little-endian integer, it will be backwards.
      scanf0_address = param0
      self.state.memory.store(scanf0_address, scanf0, endness=project.arch.memory_endness)
      scanf1_address = param1
      self.state.memory.store(scanf1_address, scanf1)

      self.state.globals['solutions'] = (scanf0, scanf1)

  scanf_symbol = '__isoc99_scanf'  # :string
  project.hook_symbol(scanf_symbol, ReplacementScanf())

  # We will call this whenever puts is called. The goal of this function is to
  # determine if the pointer passed to puts is controllable by the user, such
  # that we can rewrite it to point to the string "Good Job."
  def check_puts(state):
    # Treat the implementation of this function as if puts was just called.
    # The stack, registers, memory, etc should be set up as if the x86 call
    # instruction was just invoked (but, of course, the function hasn't copied
    # the buffers yet.)
    # The stack will look as follows:
    # ...
    # esp + 7 -> /----------------\
    # esp + 6 -> |      puts      |
    # esp + 5 -> |    parameter   |
    # esp + 4 -> \----------------/
    # esp + 3 -> /----------------\
    # esp + 2 -> |     return     |
    # esp + 1 -> |     address    |
    #     esp -> \----------------/
    # (!)
    puts_parameter = state.memory.load(state.regs.esp + 4, 4, endness=project.arch.memory_endness)

    # The following function takes a bitvector as a parameter and checks if it
    # can take on more than one value. While this does not necessary tell us we
    # have found an exploitable path, it is a strong indication that the 
    # bitvector we checked may be controllable by the user.
    # Use it to determine if the pointer passed to puts is symbolic.
    # (!)
    if state.se.symbolic(puts_parameter):
      # Determine the location of the "Good Job.\n" string. We want to print it
      # out, and we will do so by attempting to constrain the puts parameter to
      # equal it. (Hint: look at .rodata).
      # (!)
      good_job_string_address = 0x594e4257 # :integer, probably hexadecimal

      # Create an expression that will test if puts_parameter equals
      # good_job_string_address. If we add this as a constraint to our solver,
      # it will try and find an input to make this expression true.
      # (!)
      is_vulnerable_expression = puts_parameter == good_job_string_address # :boolean bitvector expression

      # Have Angr evaluate the state to determine if all the constraints can
      # be met, including the one we specified above. If it can be satisfied,
      # we have found our exploit!
      
      copied_state = state.copy()

      copied_state.add_constraints(is_vulnerable_expression)
       
      if copied_state.satisfiable():
        # Before we return, let's add the constraint to the solver for real,
        # instead of just querying whether the constraint _could_ be added.
        state.add_constraints(is_vulnerable_expression)
        return True
      else:
        return False
    else: # not path.state.se.symbolic(???)
      return False

  simulation = project.factory.simgr(initial_state)

  def is_successful(state):
    # We are looking for puts. Check that the address is at the (very) beginning
    # of the puts function. Warning: while, in theory, you could look for
    # any address in puts, if you execute any instruction that adjusts the stack
    # pointer, the stack diagram above will be incorrect. Therefore, it is
    # recommended that you check for the very beginning of puts.
    # (!)
    puts_address = 0x8048370
    if state.addr == puts_address:
      # Return True if we determine this call to puts is exploitable.
      return check_puts(state)
    else:
      # We have not yet found a call to puts; we should continue!
      return False

  # Determine the situation in which you should avoid. Optionally, you can
  # remove the avoid parameter, although it may cause the program to run more
  # slowly.
  # (!)
  simulation.explore(find=is_successful)

  if simulation.found:
    solution_state = simulation.found[0]

    (scanf0, scanf1) = solution_state.globals['solutions']
    solution = str(solution_state.se.eval(scanf0)) + ' ' + solution_state.se.eval(scanf1,cast_to=str)
    print solution
  else:
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
