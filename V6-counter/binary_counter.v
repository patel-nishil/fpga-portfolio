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