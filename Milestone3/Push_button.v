`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2024 01:56:55 PM
// Design Name: 
// Module Name: Push_button
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Push_button(
    input button, clk, reset,
    output z
);
wire async_z, sync_z, Divided;

//clockDivider clkDiv (.clk(clk), .rst(reset), .clk_out(Divided));
debouncer deb (.clk(clk), .in(button), .out(async_z), .rst(reset));
synchronizer sync (.Clk(clk), .SIG(async_z), .SIG1(sync_z));
PosEdgeDetector detector (.clk(clk), .reset(reset ), .x(sync_z), .z(z));

endmodule
