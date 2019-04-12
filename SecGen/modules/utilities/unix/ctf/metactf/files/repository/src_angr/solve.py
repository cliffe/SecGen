#!/usr/bin/pypy

import angr
import sys
import os

def main():
  proj = angr.Project(sys.argv[1])
  initial_state = proj.factory.entry_state()
  pg = proj.factory.simgr(initial_state, veritesting=False)
  pg.explore(find=lambda p: 'Good Job.' in p.posix.dumps(1))
  print pg
  print repr(pg.found[0].posix.dumps(0))

if __name__ == '__main__':
  main()
