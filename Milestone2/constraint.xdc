# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


##VGA Connector
set_property PACKAGE_PIN G19     [get_ports {vga_r[0]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[0]}]
set_property PACKAGE_PIN H19     [get_ports {vga_r[1]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[1]}]
set_property PACKAGE_PIN J19     [get_ports {vga_r[2]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[2]}]
set_property PACKAGE_PIN N19     [get_ports {vga_r[3]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[3]}]
set_property PACKAGE_PIN J17     [get_ports {vga_g[0]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[0]}]
set_property PACKAGE_PIN H17     [get_ports {vga_g[1]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[1]}]
set_property PACKAGE_PIN G17     [get_ports {vga_g[2]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[2]}]
set_property PACKAGE_PIN D17     [get_ports {vga_g[3]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[3]}]
set_property PACKAGE_PIN N18     [get_ports {vga_b[0]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[0]}]
set_property PACKAGE_PIN L18     [get_ports {vga_b[1]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[1]}]
set_property PACKAGE_PIN K18     [get_ports {vga_b[2]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[2]}]
set_property PACKAGE_PIN J18     [get_ports {vga_b[3]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[3]}]
set_property PACKAGE_PIN P19     [get_ports hsync]						
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property PACKAGE_PIN R19     [get_ports vsync]						
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

##Buttons
set_property PACKAGE_PIN W13 	 [get_ports reset]						
set_property IOSTANDARD LVCMOS33 [get_ports reset]


set_property PACKAGE_PIN V17     [get_ports up2]				
set_property IOSTANDARD LVCMOS33 [get_ports up2]

set_property PACKAGE_PIN V16     [get_ports down2]				
set_property IOSTANDARD LVCMOS33 [get_ports down2]

set_property PACKAGE_PIN T1      [get_ports up1]		
set_property IOSTANDARD LVCMOS33 [get_ports up1]

set_property PACKAGE_PIN R2     [get_ports down1]				
set_property IOSTANDARD LVCMOS33 [get_ports down1]
