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
                default: begin                 // catch invalid states
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