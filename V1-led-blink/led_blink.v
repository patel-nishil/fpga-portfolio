module led_blink (
    input  wire clk,
    output wire led
);

    // 50MHz clock -> blink at 1Hz
    // Count to 25,000,000 then toggle
    reg [24:0] counter;
    reg        led_reg;

    always @(posedge clk) begin
        if (counter == 25_000_000 - 1) begin
            counter <= 0;
            led_reg <= ~led_reg;
        end else begin
            counter <= counter + 1;
        end
    end

    assign led = led_reg;

endmodule