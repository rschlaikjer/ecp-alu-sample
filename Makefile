all: out.config

top.json:
	yosys -p "read_verilog top.v; read_verilog ymult2.v; synth_ecp5 -top top -json top.json -abc9"

out.config: top.json
	nextpnr-ecp5 --45k --package CABGA256 --speed 6 --lpf test.lpf --json top.json --textcfg out.config
