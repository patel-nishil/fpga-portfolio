# V8 — 7-Segment Display Driver

**Board:** Intel Agilex 5 DE25-Nano  
**Tool:** Quartus Prime Pro 25.1.1  
**Milestone:** V8 of the FPGA/Verilog portfolio

---

## What It Does

Implements a BCD-to-7-segment decoder displaying hex digits 0–F on an external single-digit common cathode 7-segment display. Four slide switches select the digit; the decoder drives segments a–g via the GPIO 1 (JP2) expansion header at 3.3V.

This is a purely combinational design — no clock, no registers. Outputs follow inputs with gate delay only.

---

## Hardware

**Display:** Single-digit common cathode 7-segment (ELEGOO Super Starter Kit)  
**Connection:** GPIO 1 header (JP2) on the DE25-Nano  
**Resistors:** 220Ω in series with each segment pin (limits current to ~6 mA at 3.3V)

### Wiring

| Display Pin | Signal  | 220Ω → JP2 Pin | Quartus Pin | I/O Standard |
|-------------|---------|----------------|-------------|--------------|
| a (top)     | seg_a   | JP2 pin 1      | PIN_BV14    | 3.3-V LVCMOS |
| b           | seg_b   | JP2 pin 2      | PIN_CG26    | 3.3-V LVCMOS |
| c           | seg_c   | JP2 pin 3      | PIN_DM2     | 3.3-V LVCMOS |
| d           | seg_d   | JP2 pin 4      | PIN_CD23    | 3.3-V LVCMOS |
| e           | seg_e   | JP2 pin 5      | PIN_CG23    | 3.3-V LVCMOS |
| f           | seg_f   | JP2 pin 6      | PIN_CE14    | 3.3-V LVCMOS |
| g (middle)  | seg_g   | JP2 pin 7      | PIN_CA23    | 3.3-V LVCMOS |
| COM (pin 3 & 8) | GND | JP2 pin 12    | —           | —            |

Switch inputs use the onboard pins (1.1-V standard):

| Signal | Role   | Pin      |
|--------|--------|----------|
| sw0    | BCD[0] | PIN_DK24 |
| sw1    | BCD[1] | PIN_DD24 |
| sw2    | BCD[2] | PIN_DD27 |
| sw3    | BCD[3] | PIN_DF27 |

---

## Verilog

```verilog
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
            4'd0:  seg = 7'b0111111;  // 0
            4'd1:  seg = 7'b0000110;  // 1
            4'd2:  seg = 7'b1011011;  // 2
            4'd3:  seg = 7'b1001111;  // 3
            4'd4:  seg = 7'b1100110;  // 4
            4'd5:  seg = 7'b1101101;  // 5
            4'd6:  seg = 7'b1111101;  // 6
            4'd7:  seg = 7'b0000111;  // 7
            4'd8:  seg = 7'b1111111;  // 8
            4'd9:  seg = 7'b1101111;  // 9
            4'd10: seg = 7'b1110111;  // A
            4'd11: seg = 7'b1111100;  // b
            4'd12: seg = 7'b0111001;  // C
            4'd13: seg = 7'b1011110;  // d
            4'd14: seg = 7'b1111001;  // E
            4'd15: seg = 7'b1110001;  // F
            default: seg = 7'b0000000;
        endcase
    end

    // Common cathode display: HIGH = segment ON — no inversion needed
    assign seg_a = seg[0];
    assign seg_b = seg[1];
    assign seg_c = seg[2];
    assign seg_d = seg[3];
    assign seg_e = seg[4];
    assign seg_f = seg[5];
    assign seg_g = seg[6];

endmodule
```

---

## Key Concepts Learned

**Purely combinational design:** No clock port, no registers. Outputs update immediately when inputs change. Contrast with V5–V7 where a clock was required for all state-holding behavior.

**Case statement as lookup table:** A Boolean equation for each segment would require a sum-of-products expression across all 4 input bits — 7 separate equations, each with up to 12 product terms. The `case` statement instead maps each of the 16 input combinations to a direct segment pattern. Each row is human-readable, easy to verify against a reference, and trivial to modify. Synthesis tools optimize both approaches equally in hardware.

**Mixed I/O standards:** The onboard switches use 1.1-V I/O (their native bank voltage). The GPIO header uses 3.3-V LVCMOS. Quartus handles multiple I/O standards within one design by bank — each pin's standard must match its bank voltage.

**Active-low vs active-high outputs:** Onboard LEDR LEDs are active-low (logic 0 = on), requiring output inversion. The external common cathode display is active-high (logic 1 = segment on), so no inversion is needed. The Verilog must match the hardware it drives.

**b and d are lowercase** on 7-segment hex displays to avoid confusion with 8 (B) and 0 (D).
