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
    output wire [3:0] vga_b,   // Blue color output
    input up1,
    input down1,
    input up2,
    input down2,
    output reg [6:0] segments,
    output reg [3:0] an
);
    wire [9:0] x, y;          // Pixel coordinates
    wire video_on;            // Active video region
    wire [11:0] rgb;
    wire [3:0] score1,score2;
    // Instantiate VGA Controller
    controller vga_inst (.clk(clk), .reset(reset), .H(hsync), .V(vsync), .x(x), .y(y), .video_on(video_on));
    graphics_Gen graphics (.clk(clk), .reset(reset), .up1(up1), .down1(down1), .up2(up2), .down2(down2), .video_on(video_on), .x(x), .y(y), .rgb(rgb), .score1(score1), .score2(score2));
    // BCD bcd(score1) // make bcd to display on board
    
    // Parameters for border size
    assign vga_r = rgb[11:8];  // Extract red color
    assign vga_g = rgb[7:4];   // Extract green color
    assign vga_b = rgb[3:0];   // Extract blue color
    
    reg [6:0] seg_Player1;
    reg [6:0] seg_Player2;
    always @(*) begin
    case(score1)
0: seg_Player1 = 7'b0000001;
1: seg_Player1 = 7'b1001111;
2: seg_Player1 = 7'b0010010;
3: seg_Player1 = 7'b0000110;
4: seg_Player1 = 7'b1001100;
5: seg_Player1 = 7'b0100100;
6: seg_Player1 = 7'b0100000;
7: seg_Player1 = 7'b0001111;
8: seg_Player1 = 7'b0000000;
9: seg_Player1 = 7'b0000100;
    default: seg_Player1 = 7'b1111111;
    endcase
        case(score2)
0: seg_Player2 = 7'b0000001;
1: seg_Player2 = 7'b1001111;
2: seg_Player2 = 7'b0010010;
3: seg_Player2 = 7'b0000110;
4: seg_Player2 = 7'b1001100;
5: seg_Player2 = 7'b0100100;
6: seg_Player2 = 7'b0100000;
7: seg_Player2 = 7'b0001111;
8: seg_Player2 = 7'b0000000;
9: seg_Player2 = 7'b0000100;
    default: seg_Player2 = 7'b1111111;
    endcase
    end
// Clock divider for VGA's 25 MHz input clock
        reg [14:0] refresh_counter; // 15-bit counter to divide 25 MHz clock
        wire slow_clk;              // Slow clock for display multiplexing
        
        always @(posedge clk or posedge reset) begin
            if (reset)
                refresh_counter <= 0;
            else if (refresh_counter == 24999) // Divide by 25,000
                refresh_counter <= 0;
            else
                refresh_counter <= refresh_counter + 1;
        end
        
        assign slow_clk = (refresh_counter == 24999); // Generate 1 kHz pulse
        
        reg [1:0] display_state; // 2-bit state for cycling through displays
        
        // Sequential display state machine
        always @(posedge slow_clk or posedge reset) begin
            if (reset)
                display_state <= 2'b00; // Start with Player 1's display
            else
                display_state <= display_state + 1; // Cycle through displays
        end
        
    // Multiplexing logic for 7-segment displays
    always @(*) begin
        case (display_state)
            2'b00: begin
                an = 4'b1110;       // Enable rightmost display (Player 1's digit)
                segments = seg_Player1; // Assign Player 1's score
            end
            2'b01: begin
                an = 4'b1101;       // Enable next display (Player 2's digit)
                segments = seg_Player2; // Assign Player 2's score
            end
            default: begin
                an = 4'b1111;       // Disable all displays
                segments = 7'b1111111; // Turn off all segments
            end
        endcase
    end

    endmodule
    /*assign ball = (
    (x >= 392 && x < 396 && y >= 240 && y < 244) || 
    // Top horizontal line
    (x >= 391 && x < 397 && y >= 244 && y < 248) || 
    // Right vertical line (top half)
    (x >= 390 && x < 398 && y >= 252 && y < 256) || 
    // Horizontal line connecting vertical lines (middle)
    (x >= 390 && x < 398 && y >= 256 && y < 260) || 
    (x >= 390 && x < 398 && y >= 260 && y < 264) ||
    (x >= 390 && x < 398 && y >= 240 && y < 244) || 
    (x >= 391 && x < 397 && y >= 264 && y < 268) || 
    (x >= 392 && x < 396 && y >= 268 && y < 272)  
    
    );*/
    
    
    // Parameters for ball size and initial position
    /*localparam BALL_SIZE = 8;
    reg [9:0] ball_x = 320;    // Initial X position of the ball
    reg [9:0] ball_y = 240;    // Initial Y position of the ball
    reg ball_direction_x = 1;  // Ball movement direction on X axis (1 for right, 0 for left)
    reg ball_direction_y = 1;  // Ball movement direction on Y axis (1 for down, 0 for up)

    // Ball movement logic (simple bouncing ball)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ball_x <= 320;  // Reset to center
            ball_y <= 240;  // Reset to center
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
    end

    // Ball drawing logic: Active within the ball's bounds
    assign ball_pixel = (x >= ball_x && x < ball_x + BALL_SIZE && 
                         y >= ball_y && y < ball_y + BALL_SIZE);

    // Ball position
    /*reg [9:0] ballX = 320;  // Initial X position of the ball
    reg [9:0] ballY = 240;    // Initial Y position of the ball
    localparam BALL_SIZE = 8; // Ball size

    // Ball logic: Active within the ball's bounds
    assign ball = (x >= ballX && x < ballX + BALL_SIZE && 
                   y >= ballY && y < ballY + BALL_SIZE);*/
 // "PONG" Text Logic
 

    // VGA color outputs

    //assign vga_b = video_on ? ((border|| p_pixel || o_pixel || n_pixel || g_pixel) ? 4'hF:4'hF) : 4'h0;

    // Ball movement logic (for future enhancements)
    // Add ball movement logic later if required
   /* assign vga_r = (video_on && pixel_on) ? 4'hF: 4'h0;
        assign vga_g = 4'h0;
            assign vga_b = 4'h0; */