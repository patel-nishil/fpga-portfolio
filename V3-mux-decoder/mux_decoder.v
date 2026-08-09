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

    assign led0 = ~(sw0 ? sw2 : sw1);

    assign led1 = ~((~sw0) & (~sw1));
    assign led2 = ~((~sw0) &   sw1);
    assign led3 = ~(  sw0  & (~sw1));
    assign led4 = ~(  sw0  &   sw1);

endmodule