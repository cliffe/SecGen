import angr
import claripy
import sys

def main(argv):
  path_to_binary = argv[1]
  project = angr.Project(path_to_binary)

  # You can either use a blank state or an entry state; just make sure to start
  # at the beginning of the program.
  # (!)
  initial_state = ???

  # Again, scanf needs to be replaced.
  class ReplacementScanf(angr.SimProcedure):
    # Hint: scanf("%u %20s")
    def run(self, format_string, ...???):
      # %u
      scanf0 = claripy.BVS('scanf0', ???)
      
      # %20s
      scanf1 = claripy.BVS('scanf1', ???)

      # The bitvector.chop(bits=n) function splits the bitvector into a Python
      # list containing the bitvector in segments of n bits each. In this case,
      # we are splitting them into segments of 8 bits (one byte.)
      for char in scanf1.chop(bits=8):
        # Ensure that each character in the string is printable. An interesting
        # experiment, once you have a working solution, would be to run the code
        # without constraining the characters to the capital letters.
        # Even though the solution will technically work without this, it's more
        # difficult to enter in a solution that contains character you can't
        # copy, paste, or type into your terminal or the web form that checks 
        # your solution.
        # If you are using the web form to submit answers, your solution must be
        # entirely alphanumeric except for spaces.
        # (!)
        self.state.add_constraints(char >= ???, char <= ???)

      # Warning: Endianness only applies to integers. If you store a string in
      # memory and treat it as a little-endian integer, it will be backwards.
      scanf0_address = ???
      self.state.memory.store(scanf0_address, scanf0, endness=project.arch.memory_endness)
      ...

      self.state.globals['solution0'] = ???
      ...

  scanf_symbol = ???  # :string
  project.hook_symbol(scanf_symbol, ReplacementScanf())

  # We will call this whenever puts is called. The goal of this function is to
  # determine if the pointer passed to puts is controllable by the user, such
  # that we can rewrite it to point to the string "Good Job."
  def check_puts(state):
    # Recall that puts takes one parameter, a pointer to the string it will
    # print. If we load that pointer from memory, we can analyse it to determine
    # if it can be controlled by the user input in order to point it to the
    # location of the "Good Job." string.
    #
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
    #
    # Hint: Look at level 08, 09, or 10 to review how to load a value from a
    # memory address. Remember to use the correct endianness in the future when
    # loading integers; it has been included for you here.
    # (!)
    puts_parameter = state.memory.load(???, ???, endness=project.arch.memory_endness)

    # The following function takes a bitvector as a parameter and checks if it
    # can take on more than one value. While this does not necessary tell us we
    # have found an exploitable state, it is a strong indication that the 
    # bitvector we checked may be controllable by the user.
    # Use it to determine if the pointer passed to puts is symbolic.
    # (!)
    if state.se.symbolic(???):
      # Determine the location of the "Good Job." string. We want to print it
      # out, and we will do so by attempting to constrain the puts parameter to
      # equal it. (Hint: look at .rodata).
      # Hint: use 'objdump -s <binary>' to look for the string's address.
      # (!)
      good_job_string_address = ??? # :integer, probably hexadecimal

      # Create an expression that will test if puts_parameter equals
      # good_job_string_address. If we add this as a constraint to our solver,
      # it will try and find an input to make this expression true. Take a look
      # at level 08 to remind yourself of the syntax of this.
      # (!)
      is_vulnerable_expression = ??? # :boolean bitvector expression

      # Have Angr evaluate the state to determine if all the constraints can
      # be met, including the one we specified above. If it can be satisfied,
      # we have found our exploit!
      #
      # When doing this, however, we do not want to edit our state in case we
      # have not yet found what we are looking for. To test if our expression
      # is satisfiable without editing the original, we need to clone the state.
      copied_state = state.copy()

      # We can now play around with the copied state without changing the
      # original. We need to add our vulnerable expression as a state to test it.
      # Look at level 08 and compare this call to how it is called there.
      copied_state.add_constraints(is_vulnerable_expression)

      # Finally, we test if we can satisfy the constraints of the state.
      if state.satisfiable(copied_state):
        # Before we return, let's add the constraint to the solver for real.
        state.add_constraints(is_vulnerable_expression)
        return True
      else:
        return False
    else: # not state.se.symbolic(???)
      return False

  simulation = project.factory.simgr(initial_state)

  # In order to determine if we have found a vulnerable call to 'puts',  we need
  # to run the function check_puts (defined above) whenever we reach a 'puts'
  # call. To do this, we will look for the place where the instruction pointer,
  # state.addr, is equal to the beginning of the puts function.
  def is_successful(state):
    # We are looking for puts. Check that the address is at the (very) beginning
    # of the puts function. Warning: while, in theory, you could look for
    # any address in puts, if you execute any instruction that adjusts the stack
    # pointer, the stack diagram above will be incorrect. Therefore, it is
    # recommended that you check for the very beginning of puts.
    # (!)
    puts_address = ???
    if state.addr == puts_address:
      # Return True if we determine this call to puts is exploitable.
      return check_puts(state)
    else:
      # We have not yet found a call to puts; we should continue!
      return False

  simulation.explore(find=is_successful)

  if simulation.found:
    solution_state = simulation.found[0]

    solution = ???
    print solution
  else:
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
