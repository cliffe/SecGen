# It is very useful to be able to search for a state that reaches a certain
# instruction. However, in some cases, you may not know the address of the
# specific instruction you want to reach (or perhaps there is no single
# instruction goal.) In this challenge, you don't know which instruction
# grants you success. Instead, you just know that you want to find a state where
# the binary prints "Good Job."
#
# Angr is powerful in that it allows you to search for a states that meets an
# arbitrary condition that you specify in Python, using a predicate you define
# as a function that takes a state and returns True if you have found what you
# are looking for, and False otherwise.

import angr
import sys

def main(argv):
  path_to_binary = argv[1]
  project = angr.Project(path_to_binary)
  initial_state = project.factory.entry_state()
  simulation = project.factory.simgr(initial_state)

  # Define a function that checks if you have found the state you are looking
  # for.
  def is_successful(state):
    # Dump whatever has been printed out by the binary so far into a string.
    stdout_output = state.posix.dumps(sys.stdout.fileno())

    # Return whether 'Good Job.' has been printed yet.
    # (!)
    return 'Good Job.' in stdout_output  # :boolean

  # Same as above, but this time check if the state should abort. If you return
  # False, Angr will continue to step the state. In this specific challenge, the
  # only time at which you will know you should abort is when the program prints
  # "Try again."
  def should_abort(state):
    stdout_output = state.posix.dumps(sys.stdout.fileno())
    return 'Try again.' in stdout_output  # :boolean

  # Tell Angr to explore the binary and find any state that is_successful identfies
  # as a successful state by returning True.
  simulation.explore(find=is_successful, avoid=should_abort)

  if simulation.found:
    solution_state = simulation.found[0]
    print solution_state.posix.dumps(sys.stdin.fileno())
  else:
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
