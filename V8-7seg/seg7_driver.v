module seg7_driver (
    input  wire sw0,    // BCD bit 0 (LSB)
    input  wire sw1,    // BCD bit 1
    input  wire sw2,    // BCD bit 2
    input  wire sw3,    // BCD bit 3 (MSB)
    output wire seg_a,  // top
    output wire seg_b,  // top-right
    output wire seg_c,  // bottom-right
    output wire seg_d,  // bottom
    output wire seg_e,  // bottom-left
    output wire seg_f,  // top-left
    output wire seg_g   // middle
);

    wire [3:0] bcd = {sw3, sw2, sw1, sw0};

    // seg[6:0] = {g, f, e, d, c, b, a} — 1 = segment ON
    reg [6:0] seg;

    always @(*) begin
    case (bcd)
        4'd0:  seg = 7'b0111111;  // 0 — a,b,c,d,e,f
        4'd1:  seg = 7'b0000110;  // 1 — b,c
        4'd2:  seg = 7'b1011011;  // 2 — a,b,d,e,g
        4'd3:  seg = 7'b1001111;  // 3 — a,b,c,d,g
        4'd4:  seg = 7'b1100110;  // 4 — b,c,f,g
        4'd5:  seg = 7'b1101101;  // 5 — a,c,d,f,g
        4'd6:  seg = 7'b1111101;  // 6 — a,c,d,e,f,g
        4'd7:  seg = 7'b0000111;  // 7 — a,b,c
        4'd8:  seg = 7'b1111111;  // 8 — all
        4'd9:  seg = 7'b1101111;  // 9 — a,b,c,d,f,g
        4'd10: seg = 7'b1110111;  // A — a,b,c,e,f,g
        4'd11: seg = 7'b1111100;  // b — c,d,e,f,g
        4'd12: seg = 7'b0111001;  // C — a,d,e,f
        4'd13: seg = 7'b1011110;  // d — b,c,d,e,g
        4'd14: seg = 7'b1111001;  // E — a,d,e,f,g
        4'd15: seg = 7'b1110001;  // F — a,e,f,g
        default: seg = 7'b0000000;
    endcase
end

    // Common cathode: HIGH = segment ON — no inversion
    assign seg_a = seg[0];
    assign seg_b = seg[1];
    assign seg_c = seg[2];
    assign seg_d = seg[3];
    assign seg_e = seg[4];
    assign seg_f = seg[5];
    assign seg_g = seg[6];

endmodule