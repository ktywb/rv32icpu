#!/bin/bash
cd ./OneDrive/share_OneDrive/project/

rm ./top_test.vcd
rm ./top_test.vvp
rm ./Reg_out.dat
rm ./Imem_out.dat
rm ./Dmem_out.dat
#rm ./Log_out.dat

iverilog -o top_test.vvp top_test.v
vvp top_test.vvp

#open ./top_test.vcd
#open ./OneDrive/share_OneDrive/project/Reg_out.dat 