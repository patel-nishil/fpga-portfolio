V4 — Adders (Half, Full, Ripple Carry)



Board: Intel Agilex 5 DE25-Nano

Tool: Quartus Prime Pro 25.1.1

Milestone: V4 of the FPGA/Verilog portfolio



What It Does



Implements a 2-bit ripple carry adder using hierarchical Verilog modules:



half\_adder — adds two 1-bit inputs, produces Sum and Carry

full\_adder — adds two bits plus a carry-in (built from two half adders)

ripple\_carry\_adder — chains one half adder + one full adder to add two 2-bit numbers



Inputs: two 2-bit numbers via four slide switches (A = right pair, B = left pair)

Outputs: 2-bit sum + carry-out on three LEDs



Pin Assignments

Signal	Role	Pin	I/O Standard

sw0	A\[0]	PIN\_DK24	1.1-V

sw1	A\[1]	PIN\_DD24	1.1-V

sw2	B\[0]	PIN\_DD27	1.1-V

sw3	B\[1]	PIN\_DF27	1.1-V

led0	Sum\[0]	PIN\_DF35	1.1-V

led1	Sum\[1]	PIN\_DJ32	1.1-V

led2	Cout	PIN\_DN22	1.1-V



Switch convention: UP = 0, DOWN = 1. LED ON = bit is 1, LED OFF = bit is 0 (active-low, inverted in Verilog).



Verilog

verilog

// half\_adder.v

module half\_adder (

&#x20;   input  wire a,

&#x20;   input  wire b,

&#x20;   output wire sum,

&#x20;   output wire carry

);

&#x20;   assign sum   = a ^ b;

&#x20;   assign carry = a \& b;

endmodule



// full\_adder.v

module full\_adder (

&#x20;   input  wire a,

&#x20;   input  wire b,

&#x20;   input  wire cin,

&#x20;   output wire sum,

&#x20;   output wire cout

);

&#x20;   wire sum1, carry1, carry2;



&#x20;   half\_adder ha1 (.a(a),    .b(b),   .sum(sum1), .carry(carry1));

&#x20;   half\_adder ha2 (.a(sum1), .b(cin), .sum(sum),  .carry(carry2));



&#x20;   assign cout = carry1 | carry2;

endmodule



// ripple\_carry\_adder.v

module ripple\_carry\_adder (

&#x20;   input  wire sw0,   // A\[0] — LSB of operand A

&#x20;   input  wire sw1,   // A\[1] — MSB of operand A

&#x20;   input  wire sw2,   // B\[0] — LSB of operand B

&#x20;   input  wire sw3,   // B\[1] — MSB of operand B

&#x20;   output wire led0,  // Sum\[0]

&#x20;   output wire led1,  // Sum\[1]

&#x20;   output wire led2   // Carry out

);

&#x20;   wire sum0, sum1, carry0, carry\_out;



&#x20;   half\_adder ha0 (

&#x20;       .a(sw0), .b(sw2),

&#x20;       .sum(sum0), .carry(carry0)

&#x20;   );



&#x20;   full\_adder fa1 (

&#x20;       .a(sw1), .b(sw3), .cin(carry0),

&#x20;       .sum(sum1), .cout(carry\_out)

&#x20;   );



&#x20;   // Active-low LEDs: \~bit so LED ON = 1, LED OFF = 0

&#x20;   assign led0 = \~sum0;

&#x20;   assign led1 = \~sum1;

&#x20;   assign led2 = \~carry\_out;



endmodule

Key Concepts Learned



Hierarchical design: Sub-modules (half\_adder, full\_adder) are instantiated inside the top-level module using named port connections (.portname(signal)). Only the top-level module's ports appear in the Pin Planner.



Half vs. full adder: The LSB position has no carry-in, so a 2-input half adder is sufficient. Every subsequent bit must accept the carry from the previous stage — requiring a full adder's three inputs.



Ripple carry and propagation delay: Each stage waits for the carry from the stage below it. Worst case (e.g., 11...1 + 00...1), carry ripples through every bit in series. For large N, this limits maximum clock speed. Carry-lookahead adders solve this by computing carries in parallel.

