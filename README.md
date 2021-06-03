# LS013B7DH01 Driver
I am working on a driver for LS013B7DH01 on an iCEBreaker FPGA development board


I used opensource tools. Visual Studio Code, Yosys, nextpnr and icestorm. 

# To synthesize and download the code on your icebreaker use the following 

```shell
~$ yosys -ql top_mod.yslog -p 'synth_ice40 -top lcd_driver -json top_mod.json' top_module.v clk_divider.v Sharp_Driver.v
~$ nextpnr-ice40 -ql top_mod.nplog --up5k --package sg48 --freq 12 --asc top_mod.asc --pcf icebreaker.pcf --json top_mod.json
~$ icepack top_mod.asc top_mod.bin
~$ iceprog top_mod.bin
```

# To simulate it:

```shell
~$ iverilog -Wall -o output module_tb.v clk_divider.v Sharp_Driver.v
~$ vvp -lxt2 output
~$ gtkwave test.vcd 
```
