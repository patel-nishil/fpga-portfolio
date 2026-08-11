# V6 — Counters & Clock Dividers

**Board:** Intel Agilex 5 DE25-Nano  
**Tool:** Quartus Prime Pro 25.1.1  
**Milestone:** V6 of the FPGA/Verilog portfolio

---

## What It Does

Implements a 4-bit binary counter with runtime controls for direction, enable, speed, and reset. The counter value is displayed in binary on four LEDs, counting 0–15 and wrapping.

| Switch | Role      | UP (=1)        | DOWN (=0)    |
|--------|-----------|----------------|--------------|
| SW0    | Reset     | Resets to 0000 | Normal       |
| SW1    | Direction | Count up       | Count down   |
| SW2    | Enable    | Counting       | Paused       |
| SW3    | Speed     | ~4 Hz          | ~1 Hz        |

---

## Pin Assignments

| Signal | Role        | Pin      | I/O Standard |
|--------|-------------|----------|--------------|
| clk    | 50 MHz      | PIN_DJ35 | 1.1-V        |
| sw0    | Reset       | PIN_DK24 | 1.1-V        |
| sw1    | Direction   | PIN_DD24 | 1.1-V        |
| sw2    | Enable      | PIN_DD27 | 1.1-V        |
| sw3    | Speed       | PIN_DF27 | 1.1-V        |
| led0   | bit 0 (LSB) | PIN_DF35 | 1.1-V        |
| led1   | bit 1       | PIN_DJ32 | 1.1-V        |
| led2   | bit 2       | PIN_DN22 | 1.1-V        |
| led3   | bit 3 (MSB) | PIN_DP23 | 1.1-V        |

Switch convention: UP = logic 1, DOWN = logic 0. LED ON = bit is 1 (active-low, inverted in Verilog).

---

## Verilog

```verilog
module binary_counter (
    input  wire clk,   // 50 MHz board clock
    input  wire sw0,   // synchronous reset  (UP=1 → reset to 0)
    input  wire sw1,   // direction          (UP=1 → count up, DOWN=0 → count down)
    input  wire sw2,   // enable             (UP=1 → counting,  DOWN=0 → paused)
    input  wire sw3,   // speed              (UP=1 → ~4 Hz,     DOWN=0 → ~1 Hz)
    output wire led0,  // bit 0 (LSB)
    output wire led1,  // bit 1
    output wire led2,  // bit 2
    output wire led3   // bit 3 (MSB)
);

    reg [25:0] counter;
    reg        tick;
    reg [3:0]  q;

    // Fast tick: every 12.5 M cycles = 4 Hz
    // Slow tick: every 50 M cycles   = 1 Hz
    wire [25:0] limit = sw3 ? 26'd12_499_999 : 26'd49_999_999;

    // Clock divider
    always @(posedge clk) begin
        if (counter >= limit) begin
            counter <= 0;
            tick    <= 1;
        end else begin
            counter <= counter + 1;
            tick    <= 0;
        end
    end

    // 4-bit counter: synchronous reset has priority, then tick + enable
    always @(posedge clk) begin
        if (sw0)
            q <= 4'd0;
        else if (tick && sw2)
            q <= sw1 ? q + 1 : q - 1;   // wraps: 15→0 (up) or 0→15 (down)
    end

    // Active-low LED outputs
    assign led0 = ~q[0];
    assign led1 = ~q[1];
    assign led2 = ~q[2];
    assign led3 = ~q[3];

endmodule
```

---

## Key Concepts Learned

**Synchronous vs. asynchronous reset:** A synchronous reset is checked on the rising clock edge — it appears inside `always @(posedge clk)` as a condition on the data path. An asynchronous reset bypasses the clock and fires immediately (`always @(posedge clk or posedge rst)`). FPGAs strongly prefer synchronous reset: timing tools can analyze it like any registered path, and there is no risk of a glitch on the reset line causing a spurious clear between clock edges.

**Clock divider math:** To generate a tick at frequency F from a board clock at 50 MHz, the counter limit = (50,000,000 / F) − 1. For 100 Hz: limit = 499,999. The counter runs from 0 to the limit inclusive (500,000 cycles total), then resets and fires the tick. Setting limit = 500,000 would give 500,001 cycles, producing a slightly lower frequency.

**Priority in always blocks:** When multiple conditions share one `always @(posedge clk)` block, the first matching `if` takes priority. Here, reset (sw0) overrides enable (sw2) — even while paused, a reset snap to 0000 takes effect immediately on the next clock edge.

**Active-low LEDs:** DE25-Nano LEDR outputs are active-low (logic 0 = LED on). All LED outputs are inverted so LED ON = bit is 1.