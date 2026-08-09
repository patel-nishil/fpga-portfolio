# V3 — Multiplexers & Decoders

**Board:** Intel Agilex 5 DE25-Nano  
**Tool:** Quartus Prime Pro 25.1.1  
**Milestone:** V3 of the FPGA/Verilog portfolio

---

## What It Does

Implements two fundamental digital building blocks in a single Verilog module:

- **2-to-1 MUX** — `sw0` selects between `sw1` and `sw2`. Output on `led0`.
- **2-to-4 Decoder** — `{sw0, sw1}` select one of four outputs. One LED lights per input combination. Outputs on `led1`–`led4`.

---

## Pin Assignments

| Signal | Pin       | I/O Standard |
|--------|-----------|--------------|
| sw0    | PIN_DK24  | 1.1-V        |
| sw1    | PIN_DD24  | 1.1-V        |
| sw2    | PIN_DD27  | 1.1-V        |
| led0   | PIN_DF35  | 1.1-V        |
| led1   | PIN_DJ32  | 1.1-V        |
| led2   | PIN_DN22  | 1.1-V        |
| led3   | PIN_DP23  | 1.1-V        |
| led4   | PIN_DN25  | 1.1-V        |

Switch convention: UP = logic 0, DOWN = logic 1.

---

## Verilog

```verilog
module mux_decoder (
    input  wire sw0,
    input  wire sw1,
    input  wire sw2,
    output wire led0,
    output wire led1,
    output wire led2,
    output wire led3,
    output wire led4
);
    // 2-to-1 MUX: sw0=0 selects sw1, sw0=1 selects sw2
    // Output inverted: DE25-Nano LEDs are active-low (logic 0 = LED on)
    assign led0 = ~(sw0 ? sw2 : sw1);

    // 2-to-4 decoder: {sw0, sw1} selects one of four outputs
    // Outputs inverted for active-low LEDs
    assign led1 = ~((~sw0) & (~sw1));  // selected when {sw0,sw1} = 00
    assign led2 = ~((~sw0) &   sw1);   // selected when {sw0,sw1} = 01
    assign led3 = ~(  sw0  & (~sw1));  // selected when {sw0,sw1} = 10
    assign led4 = ~(  sw0  &   sw1);   // selected when {sw0,sw1} = 11

endmodule
```

---

## Key Concepts Learned

**2-to-1 MUX:** A selector circuit. One control bit chooses which of two data inputs passes to the output. Implemented in one line using Verilog's ternary operator: `sel ? b : a`.

**2-to-4 Decoder:** Takes an N-bit binary input and asserts exactly one of 2^N output lines. Here, 2-bit input `{sw0, sw1}` drives one of four LEDs. Each output is a unique AND combination of the input bits.

**Active-low outputs:** The DE25-Nano's LEDR LEDs are wired anode-to-VCC, cathode-to-GPIO. A LOW (logic 0) on the pin sinks current and lights the LED. All outputs are inverted in Verilog so that the "selected" output is 0 (LED on) and unselected outputs are 1 (LED off).

**`assign` for combinational logic:** No clock needed. Output updates immediately whenever inputs change. Appropriate for all purely combinational circuits.