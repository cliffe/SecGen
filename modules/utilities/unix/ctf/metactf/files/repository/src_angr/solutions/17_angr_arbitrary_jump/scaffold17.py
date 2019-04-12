import angr
import claripy
import sys

def main(argv):
  path_to_binary = argv[1]
  project = angr.Project(path_to_binary)

  initial_state = ??? 

  # An under-constrained (unconstrained) state occurs when there are too many
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
  # behavior later. For now, test if a state is vulnerable by checking if we
  # can set the instruction pointer to the address of print_good in the binary.
  # (!)
  def check_vulnerable(state):
    # Reimplement me!
    return False

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
  def has_found_solution():
    return len(simulation.found) > 0

  # Check if there are still unconstrained states left to check. Once we
  # determine a given unconstrained state is not exploitable, we can throw it
  # out. Use the simulation.unconstrained list.
  # (!)
  def has_unconstrained_to_check():
    # Reimplement me! 
    pass

  # The list simulation.active is a list of all states that can be explored
  # further.
  # (!)
  def has_active():
    # Reimplement me!
    pass
  while (has_active() or has_unconstrained_to_check()) and (not has_found_solution()):
    # Iterate through all unconstrained states and check them.
    # (!)
    for unconstrained_state in ???:
      # Check if the unconstrained state is exploitable.
      # (!)
      if ???:
        # Found an exploit, exit the while loop and keep unconstrained_state as
        # the solution. The way the loops is currently set up, you should move
        # the exploitable unconstrained state to the 'found' stash.
        # A 'stash' should be a string that corresponds to a list that stores
        # all the states that the state group keeps. Values include:
        #  'active' = states that can be stepped
        #  'deadended' = states that have exited the program
        #  'errored' = states that encountered an error with Angr
        #  'unconstrained' = states that are unconstrained
        #  'found' = solutions
        #  anything else = whatever you want, perhaps you want a 'not_needed',
        #                  you can call it whatever you want

        # Moves anything in the stash 'from_stash' to the 'to_stash' if the
        # function should_move evaluates to true.
        # Reimplement this entire block of code.
        # (!)

        # def should_move(state):
        #   # Reimplement me if you decide to use me
        #   return False
        # simulation.move(from_stash, to_stash, filter_func=should_move)

        # # For example, the following moves everything in 'active' to
        # # 'not_needed' except if the state is in keep_states
        # keep_states = [ ... ]
        # def should_move(state):
        #   return state in keep_states
        # simulation.move('active', 'not_needed', filter_func=should_move)
        pass

      else: # unconstrained state is not exploitable
        # Move the unconstrained_state that you tested that doesn't work to a
        # different stash, perhaps 'not_needed'.
        # Reimplement me.
        # (!)
        pass
 
    # Advance the simulation.
    simulation.step()

  if simulation.found:
    solution_state = simulation.found[0]

    # Ensure that every printed byte is within the acceptable ASCII range (A..Z)
    for byte in solution_state.posix.files[sys.stdin.fileno()].all_bytes().chop(bits=8):
      solution_state.add_constraints(byte >= ???, byte <= ???)

    # Constrain the instruction pointer to target the print_good function and
    # then solve for the user input (recall that this is
    # 'solution_state.posix.dumps(sys.stdin.fileno())')
    # (!)
    ...

    solution = ???
    print solution
  else:
    raise Exception('Could not find the solution')

if __name__ == '__main__':
  main(sys.argv)
