`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2024 11:14:15 AM
// Design Name: 
// Module Name: top_module
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
module top_module( 
    input wire clk,           // Input clock
    input wire reset,         // Reset signal
    output wire hsync,        // Horizontal sync
    output wire vsync,        // Vertical sync
    output wire [3:0] vga_r,  // Red color output
    output wire [3:0] vga_g,  // Green color output
    output wire [3:0] vga_b   // Blue color output
);
    wire [9:0] x, y;          // Pixel coordinates
    wire video_on;            // Active video region
    wire border;              // Border signal
    wire ball;                // Ball signal

    // Instantiate VGA Controller
    controller vga_inst (.clk(clk), .reset(reset), .H(hsync), .V(vsync), .x(x), .y(y), .video_on(video_on));

    // Parameters for border size
    localparam BORDER_THICKNESS = 5;

    // Border logic: Active at the edges of the display
    assign border = (x < BORDER_THICKNESS || x >= 640 - BORDER_THICKNESS || y < BORDER_THICKNESS || y >= 480 - BORDER_THICKNESS);

    // Ball position
    /*reg [9:0] ballX = 320;    // Initial X position of the ball
    reg [9:0] ballY = 240;    // Initial Y position of the ball
    localparam BALL_SIZE = 8; // Ball size

    // Ball logic: Active within the ball's bounds
    assign ball = (x >= ballX && x < ballX + BALL_SIZE && 
                   y >= ballY && y < ballY + BALL_SIZE);*/
 // "PONG" Text Logic
 
wire p_pixel, o_pixel, n_pixel, g_pixel;
wire o_left, o_top, o_right, o_bottom;
wire n_left, n_top, n_right;
wire G_left, G_top, G_bottom, G_right, G_mid;
parameter pixel_on=0;


//assign o_pixel = o_left || o_top || o_right || o_bottom;
assign p_pixel = (
    // Left vertical line
    (x >= 280 && x < 284 && y >= 200 && y < 280) || 
    // Top horizontal line
    (x >= 284 && x < 296 && y >= 200 && y < 204) || 
    // Right vertical line (top half)
    (x >= 296 && x < 300 && y >= 200 && y < 244) || 
    // Horizontal line connecting vertical lines (middle)
    (x >= 284 && x < 296 && y >= 240 && y < 244)
);
// Modularized logic for "O"

    assign o_left = (x >= 305 && x < 309 && y >= 200 && y < 280);
    assign o_top = (x >= 309 && x < 329 && y >= 200 && y < 204);
    assign o_right = (x >= 325 && x < 329 && y >= 200 && y < 280);
    assign o_bottom = (x >= 309 && x < 329 && y >= 276 && y < 280);



    //"O"
// "O"
 /*   assign o_pixel = (
        // Left vertical line
        (x >= 305 && x < 309 && y >= 200 && y < 280) || 
        // Top horizontal line
        (x >= 309 && x < 319 && y >= 200 && y < 204) || 
        // Right vertical line
        (x >= 315 && x < 319 && y >= 200 && y < 280) || 
        // Bottom horizontal line
        (x >= 309 && x < 319 && y >= 276 && y < 280)
    );*/ //-25
    assign n_left = (x >= 334 && x < 338 && y >= 200 && y < 280);
    assign n_top = (x >= 334 && x < 354 && y >= 200 && y < 204);
    assign n_right = (x >= 350 && x < 354 && y >= 200 && y < 280);
    
    
    assign G_left = (x >= 360 && x < 364 && y >= 200 && y < 280);
    assign G_top =  (x >= 364 && x < 380 && y >= 200 && y < 204);
    assign G_bottom = (x >= 364 && x < 380 && y >= 276 && y < 280);
    assign G_mid = (x >= 372 && x < 380 && y >= 240 && y < 244);
    assign G_right = (x >= 376 && x < 380 && y >= 244 && y < 280);


    
    
    
    assign n_pixel = n_left || n_top || n_right;
    assign o_pixel = o_left || o_top || o_right || o_bottom;
    assign g_pixel = G_left || G_top || G_bottom || G_mid || G_right;
    // VGA color outputs
    assign vga_r = (video_on && (border ||/*ball*/ p_pixel || o_pixel || n_pixel || g_pixel)) ? 4'hF : 4'h0; // Red for border and ball
    assign vga_g = (video_on && (border|| p_pixel || o_pixel || n_pixel || g_pixel)) ? 4'hF : 4'h0;           // Green for border only
    //assign vga_b = (video_on && /*ball*/ (p_pixel || o_pixel || n_pixel || g_pixel)) ? 4'hF : 4'h0;             // Blue for ball only
    assign vga_b = video_on ? ((border|| p_pixel || o_pixel || n_pixel || g_pixel) ? 4'hF:4'hF) : 4'h0;
endmodule

    // Ball movement logic (for future enhancements)
    // Add ball movement logic later if required
   /* assign vga_r = (video_on && pixel_on) ? 4'hF: 4'h0;
        assign vga_g = 4'h0;
            assign vga_b = 4'h0; */