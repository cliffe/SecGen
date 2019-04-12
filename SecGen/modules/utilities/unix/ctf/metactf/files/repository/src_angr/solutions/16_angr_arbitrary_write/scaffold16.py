import angr
import claripy
import sys

def main(argv):
  path_to_binary = argv[1]
  project = angr.Project(path_to_binary)

  # You can either use a blank state or an entry state; just make sure to start
  # at the beginning of the program.
  initial_state = ???

  class ReplacementScanf(angr.SimProcedure):
    # Hint: scanf("%u %20s")
    def run(self, format_string, ...???):
      # %u
      scanf0 = claripy.BVS('scanf0', ???)
      
      # %20s
      scanf1 = claripy.BVS('scanf1', ???)

      for char in scanf1.chop(bits=8):
        self.state.add_constraints(char >= ???, char <= ???)

      scanf0_address = ???
      self.state.memory.store(scanf0_address, scanf0, endness=project.arch.memory_endness)
      ...

      self.state.globals['solutions'] = ???

  scanf_symbol = ???  # :string
  project.hook_symbol(scanf_symbol, ReplacementScanf())

  # In this challenge, we want to check strncpy to determine if we can control
  # both the source and the destination. It is common that we will be able to
  # control at least one of the parameters, (such as when the program copies a
  # string that it received via stdin).
  def check_strncpy(state):
    # The stack will look as follows:
    # ...          ________________
    # esp + 15 -> /                \
    # esp + 14 -> |     param2     |
    # esp + 13 -> |      len       |
    # esp + 12 -> \________________/
    # esp + 11 -> /                \
    # esp + 10 -> |     param1     |
    #  esp + 9 -> |      src       |
    #  esp + 8 -> \________________/
    #  esp + 7 -> /                \
    #  esp + 6 -> |     param0     |
    #  esp + 5 -> |      dest      |
    #  esp + 4 -> \________________/
    #  esp + 3 -> /                \
    #  esp + 2 -> |     return     |
    #  esp + 1 -> |     address    |
    #      esp -> \________________/
    # (!)
    strncpy_src = ???
    strncpy_dest = ???
    strncpy_len = ???

    # We need to find out if src is symbolic, however, we care about the
    # contents, rather than the pointer itself. Therefore, we have to load the
    # the contents of src to determine if they are symbolic.
    # Hint: How many bytes is strncpy copying?
    # (!)
    src_contents = state.memory.load(strncpy_src, ???)

    # Determine if the destination pointer and the source is symbolic.
    # (!)
    if state.se.symbolic(???) and ...:
      # Use ltrace to determine the password. Decompile the binary to determine
      # the address of the buffer it checks the password against. Our goal is to
      # overwrite that buffer to store the password.
      # (!)
      password_string = ??? # :string
      buffer_address = ??? # :integer, probably in hexadecimal

      # Create an expression that tests if the first n bytes is length. Warning:
      # while typical Python slices (array[start:end]) will work with bitvectors,
      # they are indexed in an odd way. The ranges must start with a high value
      # and end with a low value. Additionally, the bits are indexed from right
      # to left. For example, let a bitvector, b, equal 'ABCDEFGH', (64 bits).
      # The following will read bit 0-7 (total of 1 byte) from the right-most
      # bit (the end of the string).
      #  b[7:0] == 'H'
      # To access the beginning of the string, we need to access the last 16
      # bits, or bits 48-63:
      #  b[63:48] == 'AB'
      # In this specific case, since we don't necessarily know the length of the
      # contents (unless you look at the binary), we can use the following:
      #  b[-1:-16] == 'AB', since, in Python, -1 is the end of the list, and -16
      # is the 16th element from the end of the list. The actual numbers should
      # correspond with the length of password_string.
      # (!)
      does_src_hold_password = src_contents[???:???] == password_string
      
      # Create an expression to check if the dest parameter can be set to
      # buffer_address. If this is true, then we have found our exploit!
      # (!)
      does_dest_equal_buffer_address = ???

      # We can pass multiple expressions to extra_constraints!
      if state.satisfiable(extra_constraints=(does_src_hold_password, does_dest_equal_buffer_address)):
        state.add_constraints(does_src_hold_password, does_dest_equal_buffer_address)
        return True
      else:
        return False
    else: # not path.state.se.symbolic(???)
      return False

  simulation = project.factory.simgr(initial_state)

  def is_successful(state):
    strncpy_address = ???
    if state.addr == strncpy_address:
      return check_strncpy(state)
    else:
      return False

  simulation.explore(find=is_successful, avoid=???)

  if simulation.found:
    solution_state = simulation.found[0]

    solution = ???
    print solution
  else:
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
