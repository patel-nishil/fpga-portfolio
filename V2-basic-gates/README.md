# V1 — Quartus Setup + LED Blink
## What This Does
A Verilog module that blinks an onboard LED at 1Hz using the DE25-Nano's 50MHz 
system clock. A 25-bit counter increments on every rising clock edge and toggles 
the LED output when it reaches 25,000,000.
## Module
| Port | Direction | Description |
|------|-----------|-------------|
| clk  | input     | 50MHz system clock (PIN_DJ35) |
| led  | output    | LED0 onboard (PIN_DF35) |
## What I Learned
Introductory knowledge of Quartus Prime Pro: New Project Wizard, Verilog HDL language (.v file), Pin Planner and Assignment, Compilation Process, Programmer.
The full flow of Compilation Process: Analysis & Synthesis → Fitter → Assembler → Timing Analyzer
## Complex Issue
The most specific issue was a case-sensitivity mismatch — the Pin Planner assignment used LED (uppercase) while the Verilog port was named led (lowercase). Quartus treats these as different signals, so the LED pin had no assignment and the Assembler refused to generate the .sof file. The fix was renaming the assignment in Pin Planner to match the exact port name in the module. This introduced an important rule: signal names in Verilog and pin assignments must match exactly, case included.
## Connection to Arduino
M1 blinked an LED by calling digitalWrite() and delay() — the Arduino IDE handled everything underneath. V1 does the same thing in hardware: a counter accumulates clock cycles and a register toggles the output. The difference is that every detail is explicit — the clock source, the pin location, the I/O voltage standard, the timing constraints. Nothing is abstracted away. The result is the same blinking LED, but now you own the entire stack.