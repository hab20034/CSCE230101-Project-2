`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2024 02:23:07 PM
// Design Name: 
// Module Name: graphics_Gen
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


module graphics_Gen(
    input wire clk,           // Input clock
    input wire reset, 
    output [9:0] x, // position of pixel x from 0-799
    output [9:0] y,        // Reset signal
    output ball
    );
    
    // Define the box's position and size
    localparam BALLCENTER_X = 410;     // X coordinate of the top-left corner
    localparam BALLCENTER_Y = 250;     // Y coordinate of the top-left corner
    localparam BALLRADIUS = 50;
    localparam BALL_SIZE = 100;
    //localparam BALL_WIDTH = 20;  // Width of the box
    //localparam BALL_HEIGHT = 20; // Height of the box

    // Define the box logic: Active within the box's bounds
    
    
    reg [9:0] ball_x = 410;    // Initial X position of the ball
    reg [9:0] ball_y = 250;    // Initial Y position of the ball
    reg ball_direction_x = 1;  // Ball movement direction on X axis (1 for right, 0 for left)
    reg ball_direction_y = 1;  // Ball movement direction on Y axis (1 for down, 0 for up)

    // Ball movement logic (simple bouncing ball)
    /*always @(posedge clk or posedge reset) begin
        if (reset) begin
            ball_x <= 410;  // Reset to center
            ball_y <= 250;  // Reset to center
            ball_direction_x <= 1;  // Start moving right
            ball_direction_y <= 1;  // Start moving down
        end else begin
            // Move ball in X direction
            if (ball_direction_x) begin
                if (ball_x < 640 - BALL_SIZE)  // If not at the right edge, move right
                    ball_x <= ball_x + 1;
                else
                    ball_direction_x <= 0;  // Ball hits the right edge, change direction
            end else begin
                if (ball_x > 0)  // If not at the left edge, move left
                    ball_x <= ball_x - 1;
                else
                    ball_direction_x <= 1;  // Ball hits the left edge, change direction
            end

            // Move ball in Y direction
            if (ball_direction_y) begin
                if (ball_y < 480 - BALL_SIZE)  // If not at the bottom edge, move down
                    ball_y <= ball_y + 1;
                else
                    ball_direction_y <= 0;  // Ball hits the bottom edge, change direction
            end else begin
                if (ball_y > 0)  // If not at the top edge, move up
                    ball_y <= ball_y - 1;
                else
                    ball_direction_y <= 1;  // Ball hits the top edge, change direction
            end
        end
    end*/
    
    assign ball = ((x - ball_x) * (x - ball_x) + 
                           (y - ball_y) * (y - ball_y) <= BALLRADIUS * BALLRADIUS);
    
    // Ball logic: Active within the ball's bounds
   /* assign ball = (x >= ballX && x < ballX + BALL_SIZE && 
                   y >= ballY && y < ballY + BALL_SIZE);*/
endmodule
