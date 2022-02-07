#!/bin/bash
ADDERS=('carryRippleN_h carrySkip carryLookAhead')
mkdir -p work
cd work
# Execute
for adder in ${ADDERS[@]}; do 
	make -f ../scripts/Makefile  $adder TOP_MODULE=$adder
	make -f ../scripts/Makefile sta NETLIST=results/$adder.vg TOP_MODULE=$adder
done
cd -
# Collect Results
echo "Design,Arrival,Area" > results.rpt
for adder in ${ADDERS[@]}; do 
	echo "$adder,$(grep arrival work/reports/$adder.sta -m1 | awk '{print $1}'),$(grep "^Design Area" work/reports/$adder.sta -m1 | awk '{print $3}')" >> results.rpt	
done
