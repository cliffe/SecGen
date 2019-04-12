# Before you begin, here are a few notes about these capture-the-flag
# challenges.
#
# Each binary, when run, will ask for a password, which can be entered via stdin
# (typing it into the console.) Many of the levels will accept many different
# passwords. Your goal is to find a single password that works for each binary.
#
# If you enter an incorrect password, the program will print "Try again." If you
# enter a correct password, the program will print "Good Job."
#
# Each challenge will be accompanied by a file like this one, named
# "scaffoldXX.py". It will offer guidance as well as the skeleton of a possible
# solution. You will have to edit each file. In some cases, you will have to
# edit it significantly. While use of these files is recommended, you can write
# a solution without them, if you find that they are too restrictive.
#
# Places in the scaffoldXX.py that require a simple substitution will be marked
# with three question marks (???). Places that require more code will be marked
# with an ellipsis (...). Comments will document any new concepts, but will be
# omitted for concepts that have already been covered (you will need to use
# previous scaffoldXX.py files as a reference to solve the challenges.) If a
# comment documents a part of the code that needs to be changed, it will be
# marked with an exclamation point at the end, on a separate line (!).

import angr
import sys

def main(argv):
  # Create an Angr project.
  # If you want to be able to point to the binary from the command line, you can
  # use argv[1] as the parameter. Then, you can run the script from the command
  # line as follows:
  # python ./scaffold00.py [binary]
  # (!)
  path_to_binary = ???  # :string
  project = angr.Project(path_to_binary)

  # Tell Angr where to start executing (should it start from the main()
  # function or somewhere else?) For now, use the entry_state function
  # to instruct Angr to start from the main() function.
  initial_state = project.factory.entry_state()

  # Create a simulation manager initialized with the starting state. It provides
  # a number of useful tools to search and execute the binary.
  simulation = project.factory.simgr(initial_state)

  # Explore the binary to attempt to find the address that prints "Good Job."
  # You will have to find the address you want to find and insert it here. 
  # This function will keep executing until it either finds a solution or it 
  # has explored every possible path through the executable.
  # (!)
  print_good_address = ???  # :integer (probably in hexadecimal)
  simulation.explore(find=print_good_address)

  # Check that we have found a solution. The simulation.explore() method will
  # set simulation.found to a list of the states that it could find that reach
  # the instruction we asked it to search for. Remember, in Python, if a list
  # is empty, it will be evaluated as false, otherwise true.
  if simulation.found:
    # The explore method stops after it finds a single state that arrives at the
    # target address.
    solution_state = simulation.found[0]

    # Print the string that Angr wrote to stdin to follow solution_state. This 
    # is our solution.
    print solution_state.posix.dumps(sys.stdin.fileno())
  else:
    # If Angr could not find a path that reaches print_good_address, throw an
    # error. Perhaps you mistyped the print_good_address?
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
