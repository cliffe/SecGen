#!/bin/bash
echo "Solving all of the levels... This could take a while."
ANGR_OUT_00="$(python2 00_angr_find/solve00.py 00_angr_find/00_angr_find 2> /dev/null)"
echo -n "."
ANGR_OUT_01="$(python2 01_angr_avoid/solve01.py 01_angr_avoid/01_angr_avoid 2> /dev/null)"
echo -n "."
ANGR_OUT_02="$(python2 02_angr_find_condition/solve02.py 02_angr_find_condition/02_angr_find_condition 2> /dev/null)"
echo -n "."
ANGR_OUT_03="$(python2 03_angr_symbolic_registers/solve03.py 03_angr_symbolic_registers/03_angr_symbolic_registers 2> /dev/null)"
echo -n "."
ANGR_OUT_04="$(python2 04_angr_symbolic_stack/solve04.py 04_angr_symbolic_stack/04_angr_symbolic_stack 2> /dev/null)"
echo -n "."
ANGR_OUT_05="$(python2 05_angr_symbolic_memory/solve05.py 05_angr_symbolic_memory/05_angr_symbolic_memory 2> /dev/null)"
echo -n "."
ANGR_OUT_06="$(python2 06_angr_symbolic_dynamic_memory/solve06.py 06_angr_symbolic_dynamic_memory/06_angr_symbolic_dynamic_memory 2> /dev/null)"
echo -n "."
ANGR_OUT_07="$(python2 07_angr_symbolic_file/solve07.py 07_angr_symbolic_file/07_angr_symbolic_file 2> /dev/null)"
echo -n "."
ANGR_OUT_08="$(python2 08_angr_constraints/solve08.py 08_angr_constraints/08_angr_constraints 2> /dev/null)"
echo -n "."
ANGR_OUT_09="$(python2 09_angr_hooks/solve09.py 09_angr_hooks/09_angr_hooks 2> /dev/null)"
echo -n "."
ANGR_OUT_10="$(python2 10_angr_simprocedures/solve10.py 10_angr_simprocedures/10_angr_simprocedures 2> /dev/null)"
echo -n "."
ANGR_OUT_11="$(python2 11_angr_sim_scanf/solve11.py 11_angr_sim_scanf/11_angr_sim_scanf 2> /dev/null)"
echo -n "."
ANGR_OUT_12="$(python2 12_angr_veritesting/solve12.py 12_angr_veritesting/12_angr_veritesting 2> /dev/null)"
echo -n "."
ANGR_OUT_13="$(python2 13_angr_static_binary/solve13.py 13_angr_static_binary/13_angr_static_binary 2> /dev/null)"
echo -n "."
ANGR_OUT_14="$(python2 14_angr_shared_library/solve14.py 14_angr_shared_library/lib14_angr_shared_library.so 2> /dev/null)"
echo -n "."
ANGR_OUT_15="$(python2 15_angr_arbitrary_read/solve15.py 15_angr_arbitrary_read/15_angr_arbitrary_read 2> /dev/null)"
echo -n "."
ANGR_OUT_16="$(python2 16_angr_arbitrary_write/solve16.py 16_angr_arbitrary_write/16_angr_arbitrary_write 2> /dev/null)"
echo -n "."
ANGR_OUT_17="$(python2 17_angr_arbitrary_jump/solve17.py 17_angr_arbitrary_jump/17_angr_arbitrary_jump 2> /dev/null)"
echo -n "."
echo ""
echo "-- Solutions --"
echo "00: $ANGR_OUT_00"
echo $ANGR_OUT_00 | 00_angr_find/00_angr_find
echo "01: $ANGR_OUT_01"
echo $ANGR_OUT_01 | 01_angr_avoid/01_angr_avoid
echo "02: $ANGR_OUT_02"
echo $ANGR_OUT_02 | 02_angr_find_condition/02_angr_find_condition
echo "03: $ANGR_OUT_03"
echo $ANGR_OUT_03 | 03_angr_symbolic_registers/03_angr_symbolic_registers
echo "04: $ANGR_OUT_04"
echo $ANGR_OUT_04 | 04_angr_symbolic_stack/04_angr_symbolic_stack
echo "05: $ANGR_OUT_05"
echo $ANGR_OUT_05 | 05_angr_symbolic_memory/05_angr_symbolic_memory
echo "06: $ANGR_OUT_06"
echo $ANGR_OUT_06 | 06_angr_symbolic_dynamic_memory/06_angr_symbolic_dynamic_memory
echo "07: $ANGR_OUT_07"
echo $ANGR_OUT_07 | 07_angr_symbolic_file/07_angr_symbolic_file
echo "08: $ANGR_OUT_08"
echo $ANGR_OUT_08 | 08_angr_constraints/08_angr_constraints
echo "09: $ANGR_OUT_09"
echo $ANGR_OUT_09 | 09_angr_hooks/09_angr_hooks
echo "10: $ANGR_OUT_10"
echo $ANGR_OUT_10 | 10_angr_simprocedures/10_angr_simprocedures
echo "11: $ANGR_OUT_11"
echo $ANGR_OUT_11 | 11_angr_sim_scanf/11_angr_sim_scanf
echo "12: $ANGR_OUT_12"
echo $ANGR_OUT_12 | 12_angr_veritesting/12_angr_veritesting
echo "13: $ANGR_OUT_13"
echo $ANGR_OUT_13 | 13_angr_static_binary/13_angr_static_binary
echo "14: $ANGR_OUT_14"
BACKUP_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./14_angr_shared_library
echo $ANGR_OUT_14 | 14_angr_shared_library/14_angr_shared_library
echo "15: $ANGR_OUT_15"
export LD_LIBRARY_PATH=$BACKUP_LD_LIBRARY_PATH
echo $ANGR_OUT_15 | 15_angr_arbitrary_read/15_angr_arbitrary_read
echo "16: $ANGR_OUT_16"
echo $ANGR_OUT_16 | 16_angr_arbitrary_write/16_angr_arbitrary_write
echo "17: $ANGR_OUT_17"
echo $ANGR_OUT_17 | 17_angr_arbitrary_jump/17_angr_arbitrary_jump
