#!/bin/bash
yosys -ql top_mod.yslog -p 'synth_ice40 -top lcd_driver -json top_mod.json' top_module.v clk_divider.v Sharp_Driver.v
nextpnr-ice40 -ql top_mod.nplog --up5k --package sg48 --freq 12 --asc top_mod.asc --pcf icebreaker.pcf --json top_mod.json
icepack top_mod.asc top_mod.bin
iceprog top_mod.bin
