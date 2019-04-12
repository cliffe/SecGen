import angr
import claripy
import sys

def main(argv):
  path_to_binary = argv[1]
  project = angr.Project(path_to_binary)

  # You can either use a blank state or an entry state; just make sure to start
  # at the beginning of the program.
  initial_state = project.factory.entry_state()

  class ReplacementScanf(angr.SimProcedure):
    # Hint: scanf("%u %20s")
    def run(self, format_string, param0, param1):
      # %u
      scanf0 = claripy.BVS('scanf0', 32)

      # %20s
      scanf1 = claripy.BVS('scanf1', 20*8)

      for char in scanf1.chop(bits=8):
        self.state.add_constraints(char >= 48, char <= 96)

      scanf0_address = param0
      self.state.memory.store(scanf0_address, scanf0, endness=project.arch.memory_endness)
      scanf1_address = param1
      self.state.memory.store(scanf1_address, scanf1)

      self.state.globals['solutions'] = (scanf0, scanf1)

  scanf_symbol = '__isoc99_scanf'  # :string
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
    strncpy_src = state.memory.load(state.regs.esp + 8, 4, endness=project.arch.memory_endness)
    strncpy_dest = state.memory.load(state.regs.esp + 4, 4, endness=project.arch.memory_endness)
    strncpy_len = state.memory.load(state.regs.esp + 12, 4, endness=project.arch.memory_endness)

    # We need to find out if src is symbolic, however, we care about the
    # contents, rather than the pointer itself. Therefore, we have to load the
    # the contents of src to determine if they are symbolic.
    # Hint: How many bytes is strncpy copying?
    # (!)
    src_contents = state.memory.load(strncpy_src, strncpy_len)

    # Determine if the destination pointer and the source is symbolic.
    # (!)
    if state.se.symbolic(src_contents) and state.se.symbolic(strncpy_dest):
      # Use ltrace to determine the password. Decompile the binary to determine
      # the address of the buffer it checks the password against. Our goal is to
      # overwrite that buffer to store the password.
      # (!)
      password_string = 'DVTBOGZL' # :string
      buffer_address = 0x4655544c # :integer, probably in hexadecimal

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
      # (!)
      does_src_hold_password = src_contents[-1:-64] == password_string

      # Create an expression to check if the dest parameter can be set to
      # buffer_address. If this is true, then we have found our exploit!
      # (!)
      does_dest_equal_buffer_address = strncpy_dest == buffer_address

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
    strncpy_address = 0x8048410
    if state.addr == strncpy_address:
      return check_strncpy(state)
    else:
      return False

  simulation.explore(find=is_successful)
  if simulation.found:
    solution_state = simulation.found[0]

    scanf0, scanf1 = solution_state.globals['solutions']
    solution = str(solution_state.se.eval(scanf0)) + ' ' + solution_state.se.eval(scanf1, cast_to=str)
    print solution
  else:
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
