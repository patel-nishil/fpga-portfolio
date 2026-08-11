# V5 — D Flip-Flop & Registers

**Board:** Intel Agilex 5 DE25-Nano  
**Tool:** Quartus Prime Pro 25.1.1  
**Milestone:** V5 of the FPGA/Verilog portfolio

---

## What It Does

Implements a 3-bit D register with synchronous load enable and a built-in clock divider:

- SW[0:2] are the 3-bit data input (D)
- SW3 is the load enable — when UP (logic 1), the register captures D on each tick
- LED[0:2] show the registered output Q (holds last loaded value when SW3 is DOWN)
- LED3 blinks at ~1 Hz as a heartbeat to confirm the clock is running

The design demonstrates "sample and hold" — flip-flops capture input only on a clock edge, then hold that value until the next enabled capture.

---

## Pin Assignments

| Signal | Role          | Pin      | I/O Standard |
|--------|---------------|----------|--------------|
| clk    | 50 MHz clock  | PIN_DJ35 | 1.1-V        |
| sw0    | D[0]          | PIN_DK24 | 1.1-V        |
| sw1    | D[1]          | PIN_DD24 | 1.1-V        |
| sw2    | D[2]          | PIN_DD27 | 1.1-V        |
| sw3    | Load enable   | PIN_DF27 | 1.1-V        |
| led0   | Q[0]          | PIN_DF35 | 1.1-V        |
| led1   | Q[1]          | PIN_DJ32 | 1.1-V        |
| led2   | Q[2]          | PIN_DN22 | 1.1-V        |
| led3   | Heartbeat     | PIN_DP23 | 1.1-V        |

Switch convention: UP = logic 1, DOWN = logic 0. LED ON = bit is 1 (active-low, inverted in Verilog).

---

## Verilog

```verilog
module d_register (
    input  wire clk,    // 50 MHz board clock
    input  wire sw0,    // D[0]
    input  wire sw1,    // D[1]
    input  wire sw2,    // D[2]
    input  wire sw3,    // load enable
    output wire led0,   // Q[0]
    output wire led1,   // Q[1]
    output wire led2,   // Q[2]
    output wire led3    // heartbeat — blinks at ~1 Hz so you can see the clock running
);

    reg [24:0] counter;
    reg        heartbeat;
    reg        tick;      // single-cycle pulse every ~0.5 s
    reg [2:0]  q;

    // Clock divider: pulse tick high for one cycle every 25 million cycles (~0.5 s)
    always @(posedge clk) begin
        if (counter == 25'd24_999_999) begin
            counter   <= 0;
            heartbeat <= ~heartbeat;
            tick      <= 1;
        end else begin
            counter <= counter + 1;
            tick    <= 0;
        end
    end

    // 3-bit D register with synchronous load enable
    // Everything clocked by the main 50 MHz clock — no derived clocks
    always @(posedge clk) begin
        if (tick && sw3)
            q <= {sw2, sw1, sw0};
    end

    // Active-low LED outputs
    assign led0 = ~q[0];
    assign led1 = ~q[1];
    assign led2 = ~q[2];
    assign led3 = ~heartbeat;  // blinks at ~1 Hz

endmodule
```

---

## Key Concepts Learned

**Latch vs. flip-flop:** A latch is level-sensitive — it passes data through whenever the enable is high. A flip-flop is edge-triggered — it captures data only on the rising (or falling) clock edge. FPGAs have dedicated flip-flop hardware in every logic element; latches must be synthesized from gates, introducing timing hazards where a glitch on the enable can corrupt the stored value.

**Synchronous load enable:** `sw3` is a condition inside `always @(posedge clk)` — the 50 MHz clock still drives the flip-flop, and sw3 controls whether the load happens on that edge. Using sw3 directly as the clock (`always @(posedge sw3)`) would create a gated clock: switch bounce generates spurious edges, and Quartus cannot properly analyze timing on an uncontrolled signal used as a clock.

**Clock enable vs. derived clock:** Using a `tick` pulse as a clock enable (all logic in one `always @(posedge clk)` block) keeps the design in a single clock domain. This is the correct FPGA pattern — never derive a slower clock by toggling a register and using it in a second `always` block.

**Active-low LEDs:** DE25-Nano LEDR outputs are active-low (logic 0 = LED on). All LED outputs are inverted in Verilog so that LED ON = bit is 1.