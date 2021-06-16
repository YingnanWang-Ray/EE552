#!/bin/tcsh
set design = ArbiterMergeTest
if ( $1 == "skip" ) goto compile 
echo "Checking Syntax of The Input File Using vlog ..."   
vlib work
vlog ${design}_csp.sv +incdir+$PROTEUS_PDK_PATH
if ($status != 0) exit(1)
echo "Running svc2rtl \n";
time svc2rtl ${design}_csp.sv ${design}.rtl.sv > & /dev/null
if ($status != 0) exit(1)
echo "Formatting Verilog Output";
iStyle ${design}.rtl.sv --style=ansi -s1 -M1 -m1 -E
echo "RTL complete";
if ($status != 0) exit(1)
echo "Running RC... \n";
time proteus-a --include=${design}.config --sv=1 --task=rc --force=1
if ($status != 0) exit(1)
echo "Running clockfree... \n";
time proteus-a --include=${design}.config --sv=1 --task=clockfree --force=1
if ($status != 0) exit(1)
echo "Running encounter... \n";
#time proteus-a --include=${design}.config --sv=1 --task=encounter --force=1
echo "Reading total number of gates in RC results"
grep -C 5 "START: generating verilog" *.qdi/*rc.out | grep total
compile:
echo "Compiling the post synthesis top level file in Modelsim"
#vlog ${design}_csp_gold.sv +incdir+$PROTEUS_PDK_PATH
vlog ${design}.qdi.noclk.flat.cosim.sv
#vlog ${design}_tb.sv +incdir+$PROTEUS_PDK_PATH
echo "Creating Modelsim do file"
/usr/bin/rm run.do
echo "cd `pwd`" > run.do
echo "vsim work.${design}_cosim_tb -L $PROTEUS_PDK_PATH/qdi.synth -L $PROTEUS_PDK_PATH/svclib" >> run.do
echo "Successful Synthesis & Compilation!"
vsim -do run.do
