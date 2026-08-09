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