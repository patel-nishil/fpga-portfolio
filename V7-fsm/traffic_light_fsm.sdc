create_clock -period 20.000 -name clk [get_ports {clk}]
set_input_delay  -clock clk -max 0 [get_ports {sw0}]
set_output_delay -clock clk -max 0 [get_ports {led*}]