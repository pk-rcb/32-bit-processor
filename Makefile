# 32-bit MIPS 5-Stage Pipelined Processor Makefile

CC = iverilog
CFLAGS = -g2012
SIM = vvp
VIEWER = gtkwave

TB = tb/MIPS_Processor_tb.v
VVP_OUT = sim.vvp
VCD_OUT = mips_processor.vcd
GTKW_FILE = tb/gtkwave_signals.gtkw

.PHONY: all compile sim wave clean

all: sim

compile: $(VVP_OUT)

$(VVP_OUT): $(TB)
	$(CC) $(CFLAGS) -o $(VVP_OUT) $(TB)

sim: $(VVP_OUT)
	$(SIM) $(VVP_OUT)

wave: sim
	$(VIEWER) $(VCD_OUT) $(GTKW_FILE) &

clean:
	rm -f $(VVP_OUT) $(VCD_OUT)
