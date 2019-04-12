# An unconstrained state occurs when there are too many
# possible branches from a single instruction. This occurs, among other ways,
# when the instruction pointer (on x86, eip) is completely symbolic, meaning
# that user input can control the address of code the computer executes.
# For example, imagine the following pseudo assembly:
#
# mov user_input, eax
# jmp eax
#
# The value of what the user entered dictates the next instruction. This
# is an unconstrained state. It wouldn't usually make sense for the execution
# engine to continue. (Where should the program jump to if eax could be
# anything?) Normally, when Angr encounters an unconstrained state, it throws
# it out. In our case, we want to exploit the unconstrained state to jump to
# a location of our choosing. We will get to how to disable Angr's default
# behavior later.
#
# This challenge represents a classic stack-based buffer overflow attack to
# overwrite the return address and jump to a function that prints "Good Job."
# Our strategy for solving the challenge is as follows:
# 1. Initialize the simulation and ask Angr to record unconstrained states.
# 2. Step through the simulation until we have found a state where eip is
#    symbolic.
# 3. Constrain eip to equal the address of the "print_good" function.

import angr
import claripy
import sys

def main(argv):
  path_to_binary = argv[1]
  project = angr.Project(path_to_binary)

  initial_state = ??? 

  # The save_unconstrained=True parameter specifies to Angr to not throw out
  # unconstrained states. Instead, it will move them to the list called
  # 'simulation.unconstrained'.
  simulation = project.factory.simgr(initial_state, save_unconstrained=True)

  # Explore will not work for us, since the method specified with the 'find'
  # parameter will not be called on an unconstrained state. Instead, we want to
  # explore the binary ourselves.
  # To get started, construct an exit condition to know when we've found a
  # solution. We will later be able to move states from the unconstrained list
  # to the simulation.found list. Alternatively, you can create a boolean value
  # that serves the same purpose.
  
  # We will set this to the exploitable state once we find it.
  solution_state = None
  def has_found_solution():
    return solution_state is not None

  # Check if there are still unconstrained states left to check. Once we
  # determine a given unconstrained state is not exploitable, we can throw it
  # out. Use the simulation.unconstrained list.
  def has_unconstrained():
    return len(simulation.unconstrained) > 0

  # The list simulation.active is a list of all states that can be explored
  # further.
  # (!)
  def has_active():
    # Reimplement me! See below to see how this is used. Hint: should look very
    # similar to has_unconstrained()
    pass

  while (has_active() or has_unconstrained()) and (not has_found_solution()):
    # Check every unconstrained state that the simulation has found so far.
    # (!)
    for unconstrained_state in simulation.unconstrained:
      # Get the eip register (review 03_angr_symbolic_registers).
      # (!)
      eip = unconstrained.regs.???

      # Check if we can set the state to our print_good function.
      # (!)
      if state.satisfiable(extra_constraints=(eip == ???):
        # We can!
        solution_state = unconstrained_state

        # Now, constrain eip to equal the address of the print_good function.
        # (!)
        ...

        break

    # Since we already checked all of the unconstrained states and did not find
    simulation.drop(stash='unconstrained')

    # Advance the simulation.
    simulation.step()

  if solution_state:
    # Ensure that every printed byte is within the acceptable ASCII range (A..Z)
    for byte in solution_state.posix.files[sys.stdin.fileno()].all_bytes().chop(bits=8):
      solution_state.add_constraints(byte >= ???, byte <= ???)

    # Solve for the user input (recall that this is
    # 'solution_state.posix.dumps(sys.stdin.fileno())')
    # (!)
    ...

    solution = ???
    print solution
  else:
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
