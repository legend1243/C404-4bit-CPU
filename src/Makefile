IN = ../src/testbench.v
OUT = ./build/C404.vvp

all:
	iverilog -o $(OUT) $(IN)
	vvp $(OUT) -fst
	gtkwave ./build/wave.vcd