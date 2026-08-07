module basic_gates (
    input  wire sw0,
    input  wire sw1,
    output wire led0,
    output wire led1,
    output wire led2,
    output wire led3
);

    assign led0 = sw0 & sw1;   // AND
    assign led1 = sw0 | sw1;   // OR
    assign led2 = ~sw0;         // NOT
    assign led3 = sw0 ^ sw1;   // XOR

endmodule