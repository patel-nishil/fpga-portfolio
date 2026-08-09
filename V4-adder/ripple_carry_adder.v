module ripple_carry_adder (
    input  wire sw0,   // A[0] — LSB of operand A
    input  wire sw1,   // A[1] — MSB of operand A
    input  wire sw2,   // B[0] — LSB of operand B
    input  wire sw3,   // B[1] — MSB of operand B
    output wire led0,  // Sum[0]
    output wire led1,  // Sum[1]
    output wire led2   // Carry out
);
    wire sum0, sum1, carry0, carry_out;

    // Bit 0: half adder (no carry in at LSB)
    half_adder ha0 (
        .a(sw0), .b(sw2),
        .sum(sum0), .carry(carry0)
    );

    // Bit 1: full adder (carry ripples in from bit 0)
    full_adder fa1 (
        .a(sw1), .b(sw3), .cin(carry0),
        .sum(sum1), .cout(carry_out)
    );

    // Active-low LEDs: ~bit so LED ON = 1, LED OFF = 0
    assign led0 = ~sum0;
    assign led1 = ~sum1;
    assign led2 = ~carry_out;

endmodule