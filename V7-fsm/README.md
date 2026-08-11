# V7 — FSM in Verilog (Traffic Light Controller)

**Board:** Intel Agilex 5 DE25-Nano  
**Tool:** Quartus Prime Pro 25.1.1  
**Milestone:** V7 of the FPGA/Verilog portfolio

---

## What It Does

Implements a 3-state traffic light FSM (RED → GREEN → YELLOW → RED) with a 1 Hz tick clock and a synchronous emergency reset. Directly mirrors the M5 Arduino traffic light, showing how the same FSM logic translates from C++ software to Verilog hardware description.

| State  | Duration | LED   |
|--------|----------|-------|
| RED    | 3 s      | led0  |
| GREEN  | 3 s      | led1  |
| YELLOW | 1 s      | led2  |

SW0 UP (logic 1) forces an immediate synchronous return to RED from any state.

---

## Pin Assignments

| Signal | Role   | Pin      | I/O Standard |
|--------|--------|----------|--------------|
| clk    | 50 MHz | PIN_DJ35 | 1.1-V        |
| sw0    | Reset  | PIN_DK24 | 1.1-V        |
| led0   | RED    | PIN_DF35 | 1.1-V        |
| led1   | GREEN  | PIN_DJ32 | 1.1-V        |
| led2   | YELLOW | PIN_DN22 | 1.1-V        |

Switch convention: UP = logic 1, DOWN = logic 0. Active-low LEDs — logic 0 = LED on.

---

## Verilog

```verilog
module traffic_light_fsm (
    input  wire clk,   // 50 MHz board clock
    input  wire sw0,   // emergency reset — UP(1) forces back to RED instantly
    output wire led0,  // RED
    output wire led1,  // GREEN
    output wire led2   // YELLOW
);

    // State encoding
    localparam RED    = 2'd0;
    localparam GREEN  = 2'd1;
    localparam YELLOW = 2'd2;

    // 1 Hz tick generator
    reg [25:0] clk_div;
    reg        tick;

    always @(posedge clk) begin
        if (clk_div == 26'd49_999_999) begin
            clk_div <= 0;
            tick    <= 1;
        end else begin
            clk_div <= clk_div + 1;
            tick    <= 0;
        end
    end

    // State register and timer
    reg [1:0] state;
    reg [2:0] timer;   // counts elapsed ticks in the current state

    always @(posedge clk) begin
        if (sw0) begin             // synchronous emergency reset
            state <= RED;
            timer <= 0;
        end else if (tick) begin
            case (state)
                RED: begin
                    if (timer == 3'd2) begin   // 3 seconds (ticks 0, 1, 2)
                        state <= GREEN;
                        timer <= 0;
                    end else
                        timer <= timer + 1;
                end
                GREEN: begin
                    if (timer == 3'd2) begin   // 3 seconds
                        state <= YELLOW;
                        timer <= 0;
                    end else
                        timer <= timer + 1;
                end
                YELLOW: begin
                    if (timer == 3'd0) begin   // 1 second
                        state <= RED;
                        timer <= 0;
                    end else
                        timer <= timer + 1;
                end
                default: begin                 // catch invalid states at power-up
                    state <= RED;
                    timer <= 0;
                end
            endcase
        end
    end

    // Output logic: depends only on current state (Moore FSM)
    reg red_out, green_out, yellow_out;
    always @(*) begin
        red_out    = (state == RED);
        green_out  = (state == GREEN);
        yellow_out = (state == YELLOW);
    end

    // Active-low LED outputs
    assign led0 = ~red_out;
    assign led1 = ~green_out;
    assign led2 = ~yellow_out;

endmodule
```

---

## Key Concepts Learned

**Moore vs. Mealy FSM:** A Moore FSM's outputs depend only on the current state. A Mealy FSM's outputs depend on both the current state and the current inputs. This design is Moore — the LED outputs are determined entirely by `state`, with no input signals in the output logic. The emergency reset (`sw0`) affects state transitions only, not outputs directly.

**Two-process FSM style:** One sequential `always @(posedge clk)` block owns the state register and timer. One combinational `always @(*)` block owns the output logic. Keeping them separate makes the FSM easier to read and modify.

**`default` case:** Even though only three states are defined, the state register is 2 bits wide — meaning states 2'd3 is technically reachable from a power-up glitch or bit error. The `default` case catches any invalid state and returns the FSM to RED, preventing undefined behavior.

**C++ to Verilog FSM mapping:**
- `enum` states → `localparam` state encoding
- `switch (state)` → `case (state)`
- `millis()` timer → clock divider + tick counter
- `digitalWrite()` → combinational output logic driven by state