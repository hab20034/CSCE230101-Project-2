`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2024 07:32:32 PM
// Design Name: 
// Module Name: controller
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

module controller(
    input clk,
    input reset,
    output H,
    output V,
    output Clock_25, //To get 25MHZ for the VGA
    output [9:0] x, // position of pixel x from 0-799
    output [9:0] y, // position of pixel y from 0-524
    output video_on //To check that x and y are within the area
    );
    //This will be based on the fact that the resolution for our monitors is 640x480:
    
    // The horizontal width is 800 pixels and partitioned (same as manual)
    parameter H_DISPLAY = 640; // horizontal display width
    parameter H_FRONT = 48;// right border (front porch)
    parameter H_BACK = 16;// left border (back porch)
    parameter H_SYNC = 96; // horizontal sync width
    parameter HMAX = (H_DISPLAY + H_BACK + H_FRONT + H_SYNC) -1; // max value of horizontal counter = 799
    
    // The horizontal width is 524 pixels and partitioned (same as manual)
    parameter V_DISPLAY = 480;// vertical display area length in pixels 
    parameter V_TOP = 10;// vertical top border 
    parameter V_BOTTOM = 33; // vertical bottom border 
    parameter V_SYNC = 2; // vertical sync # lines 
    parameter VMAX = (V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC)-1 ; // max value of vertical counter = 524   
   
    parameter HSYNC_START = H_DISPLAY + H_BACK;
    parameter HSYNC_END = H_DISPLAY + H_BACK + H_SYNC - 1;
    parameter VSYNC_START = V_DISPLAY + V_BOTTOM;
    parameter VSYNC_END = V_DISPLAY + V_BOTTOM + V_SYNC - 1;

    //Clock Divider:
	reg  toggle_first, toggle_second;
	wire wire_25MHz;
   // reg  [1:0] reg_25MHz;
    
always @(posedge clk or posedge reset) begin
        if (reset) begin
            toggle_first <= 0;
            toggle_second <= 0;
        end else begin
            toggle_first <= ~toggle_first; // Divide by 2
            if (toggle_first == 1)        // Toggle second flip-flop on falling edge of toggle_first
                toggle_second <= ~toggle_second;
        end
    end
    
    assign wire_25MHz = toggle_second; // Output 25 MHz clock

    reg [9:0] hCounterReg, hCountNext; //To keep track of the pixel position and to have the next one as well to avoid glitches
    reg [9:0] vCountReg, vCountNext;
    
    // Output Buffers
    reg HSYNC_REG, VSYNC_REG;
    wire HSYNC_NEXT, VSYNC_NEXT;
    
    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            vCountReg <= 0;
            hCounterReg <= 0;
            HSYNC_REG  <= 1'b0;
            VSYNC_REG  <= 1'b0;
        end
        else begin
            vCountReg <= vCountNext;
            hCounterReg <= hCountNext;
            HSYNC_REG  <= HSYNC_NEXT;
            VSYNC_REG  <= VSYNC_NEXT;
        end
         
    //Logic for both horizontal and vertical counter
    always @(posedge wire_25MHz or posedge reset) begin
        if(reset) begin
            hCountNext = 0;
            vCountNext = 0;
            end
        else begin
            if(hCounterReg == HMAX)begin //Reached the end
                hCountNext <= 0;
            if( vCountReg == VMAX)
                vCountNext <= 0;
               else 
               vCountNext <= vCountReg + 1;
               end
            else begin
                hCountNext <= hCounterReg + 1; 
                vCountNext <= vCountReg;
                end 
                end     
  end
 //Sync signals:
    assign HSYNC_NEXT = (hCounterReg >= HSYNC_START && hCounterReg <= HSYNC_END);
    assign VSYNC_NEXT = (vCountReg >= VSYNC_START && vCountReg <= VSYNC_END);
    
    //Turn video On when the display is within the area:
    assign video_on = (hCounterReg < H_DISPLAY) && (vCountReg < V_DISPLAY); // from 0-639 and 0-479
            
    // Outputs
    assign H = HSYNC_REG;
    assign V = VSYNC_REG;
    assign x = hCounterReg;
    assign y = vCountReg;
    assign Clock_25 = wire_25MHz;
            
endmodule
