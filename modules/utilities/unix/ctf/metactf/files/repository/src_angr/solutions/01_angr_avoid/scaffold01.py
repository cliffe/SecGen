import angr
import sys

def main(argv):
  path_to_binary = ???
  project = angr.Project(path_to_binary)
  initial_state = project.factory.entry_state()
  simulation = project.factory.simgr(initial_state)

  # Explore the binary, but this time, instead of only looking for a state that
  # reaches the print_good_address, also find a state that does not reach 
  # will_not_succeed_address. The binary is pretty large, to save you some time,
  # everything you will need to look at is near the beginning of the address 
  # space.
  # (!)
  print_good_address = ???
  will_not_succeed_address = ???
  simulation.explore(find=print_good_address, avoid=will_not_succeed_address)

  if simulation.found:
    solution_state = simulation.found[0]
    print solution_state.posix.dumps(sys.stdin.fileno())
  else:
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
