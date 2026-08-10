\# V7 — FSM in Verilog (Traffic Light Controller)



\*\*Board:\*\* Intel Agilex 5 DE25-Nano  

\*\*Tool:\*\* Quartus Prime Pro 25.1.1  

\*\*Milestone:\*\* V7 of the FPGA/Verilog portfolio



\---



\## What It Does



Implements a 3-state traffic light FSM (RED → GREEN → YELLOW → RED) with a 1 Hz tick clock and a synchronous emergency reset. Directly mirrors the M5 Arduino traffic light, showing how the same FSM logic translates from C++ software to Verilog hardware description.



| State  | Duration | LED   |

|--------|----------|-------|

| RED    | 3 s      | led0  |

| GREEN  | 3 s      | led1  |

| YELLOW | 1 s      | led2  |



SW0 UP (logic 1) forces an immediate synchronous return to RED from any state.



\---



\## Pin Assignments



| Signal | Role   | Pin      | I/O Standard |

|--------|--------|----------|--------------|

| clk    | 50 MHz | PIN\_DJ35 | 1.1-V        |

| sw0    | Reset  | PIN\_DK24 | 1.1-V        |

| led0   | RED    | PIN\_DF35 | 1.1-V        |

| led1   | GREEN  | PIN\_DJ32 | 1.1-V        |

| led2   | YELLOW | PIN\_DN22 | 1.1-V        |



Switch convention: UP = logic 1, DOWN = logic 0. Active-low LEDs — logic 0 = LED on.



\---



\## Verilog



```verilog

module traffic\_light\_fsm (

&#x20;   input  wire clk,   // 50 MHz board clock

&#x20;   input  wire sw0,   // emergency reset — UP(1) forces back to RED instantly

&#x20;   output wire led0,  // RED

&#x20;   output wire led1,  // GREEN

&#x20;   output wire led2   // YELLOW

);



&#x20;   // State encoding

&#x20;   localparam RED    = 2'd0;

&#x20;   localparam GREEN  = 2'd1;

&#x20;   localparam YELLOW = 2'd2;



&#x20;   // 1 Hz tick generator

&#x20;   reg \[25:0] clk\_div;

&#x20;   reg        tick;



&#x20;   always @(posedge clk) begin

&#x20;       if (clk\_div == 26'd49\_999\_999) begin

&#x20;           clk\_div <= 0;

&#x20;           tick    <= 1;

&#x20;       end else begin

&#x20;           clk\_div <= clk\_div + 1;

&#x20;           tick    <= 0;

&#x20;       end

&#x20;   end



&#x20;   // State register and timer

&#x20;   reg \[1:0] state;

&#x20;   reg \[2:0] timer;   // counts elapsed ticks in the current state



&#x20;   always @(posedge clk) begin

&#x20;       if (sw0) begin             // synchronous emergency reset

&#x20;           state <= RED;

&#x20;           timer <= 0;

&#x20;       end else if (tick) begin

&#x20;           case (state)

&#x20;               RED: begin

&#x20;                   if (timer == 3'd2) begin   // 3 seconds (ticks 0, 1, 2)

&#x20;                       state <= GREEN;

&#x20;                       timer <= 0;

&#x20;                   end else

&#x20;                       timer <= timer + 1;

&#x20;               end

&#x20;               GREEN: begin

&#x20;                   if (timer == 3'd2) begin   // 3 seconds

&#x20;                       state <= YELLOW;

&#x20;                       timer <= 0;

&#x20;                   end else

&#x20;                       timer <= timer + 1;

&#x20;               end

&#x20;               YELLOW: begin

&#x20;                   if (timer == 3'd0) begin   // 1 second

&#x20;                       state <= RED;

&#x20;                       timer <= 0;

&#x20;                   end else

&#x20;                       timer <= timer + 1;

&#x20;               end

&#x20;               default: begin                 // catch invalid states at power-up

&#x20;                   state <= RED;

&#x20;                   timer <= 0;

&#x20;               end

&#x20;           endcase

&#x20;       end

&#x20;   end



&#x20;   // Output logic: depends only on current state (Moore FSM)

&#x20;   reg red\_out, green\_out, yellow\_out;

&#x20;   always @(\*) begin

&#x20;       red\_out    = (state == RED);

&#x20;       green\_out  = (state == GREEN);

&#x20;       yellow\_out = (state == YELLOW);

&#x20;   end



&#x20;   // Active-low LED outputs

&#x20;   assign led0 = \~red\_out;

&#x20;   assign led1 = \~green\_out;

&#x20;   assign led2 = \~yellow\_out;



endmodule

```



\---



\## Key Concepts Learned



\*\*Moore vs. Mealy FSM:\*\* A Moore FSM's outputs depend only on the current state. A Mealy FSM's outputs depend on both the current state and the current inputs. This design is Moore — the LED outputs are determined entirely by `state`, with no input signals in the output logic. The emergency reset (`sw0`) affects state transitions only, not outputs directly.



\*\*Two-process FSM style:\*\* One sequential `always @(posedge clk)` block owns the state register and timer. One combinational `always @(\*)` block owns the output logic. Keeping them separate makes the FSM easier to read and modify.



\*\*`default` case:\*\* Even though only three states are defined, the state register is 2 bits wide — meaning states 2'd3 is technically reachable from a power-up glitch or bit error. The `default` case catches any invalid state and returns the FSM to RED, preventing undefined behavior.



\*\*C++ to Verilog FSM mapping:\*\*

\- `enum` states → `localparam` state encoding

\- `switch (state)` → `case (state)`

\- `millis()` timer → clock divider + tick counter

\- `digitalWrite()` → combinational output logic driven by state

```

