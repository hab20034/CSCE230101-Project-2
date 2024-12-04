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
  reg [1:0] state, nextState; 
    parameter [1:0] start = 2'b00, play=2'b01, gameOver=2'b10;                                                                                                                         
    wire [9:0] x, y;          // Pixel coordinates                                                                             
   wire [1:0] win;
    wire video_on;            // Active video region                                                                           
    wire [11:0] rgb;                                                                                                           
    wire [11:0] text_rgb;                                                                                                      
    wire [3:0] score1,score2;         
    wire game_over_on;                                                                                         
    wire border,pad1_on, pad2_on, ball_on, score_on, p_pixel, o_pixel, n_pixel, g_pixel; 
  //  wire [1:0] win;   
 wire player_win_on;
 wire start_on;
    // Instantiate VGA Controller
   controller vga_inst (.clk(clk), .reset(reset), .H(hsync), .V(vsync), .x(x), .y(y), .video_on(video_on));                   
        graphics_Gen graphics (.clk(clk), .reset(reset), .up1(up1), .down1(down1), .up2(up2), .down2(down2), .video_on(video_on), .x(x), .y(y), .rgb(rgb), .score1(score1), .score2(score2), .border(border), .pad1On(pad1_on), .pad2On(pad2_on), .ballOn(ball_on), .p_pixel(p_pixel), .o_pixel(o_pixel), .n_pixel(n_pixel), .g_pixel(g_pixel), .state(state), .winner(win));//*, .Win1(win1), .Win2(win2)*/);
        // BCD bcd(score1) // make bcd to display on board                                                                         
        textGen score (.clk(clk), .x(x), .y(y), .dig0(score1), .dig1(score2), .ball(rgb), .text_rgb(text_rgb), .score_on(score_on), .state(state), .game_over_on(game_over_on), .player_win_on(player_win_on), .start_on(start_on));
 always@(posedge clk or posedge reset) begin
                   if(reset)
                       state<= start;
                   else state<=nextState;
                   end 
               always@(state or score1 or score2 or reset)begin
               case(state)
               start: if(up1) nextState = play;
               else nextState = start;
                   play: if(score1==10 | score2==10) nextState = gameOver;
                           else nextState = play;
                   gameOver: if(reset) nextState = start;
                               else nextState = gameOver;
                   default: nextState = start;
                   endcase
                   end      
                                                                                                                   
        // Parameters for border size                                                                                              
        // Blending RGB values from graphics and text                                                                              
    assign vga_r = (video_on) ?                                                                                                    
                   ((ball_on) ? 4'hF :  // Fuchsia for ball (RGB: 1111 0000)                                                       
                   (pad1_on) ? 4'h2 :  // Green for left paddle (RGB: 0010)                                                        
                   (pad2_on) ? 4'h5 :  // Purple for right paddle (RGB: 0101)                                                      
                   (score_on || game_over_on || player_win_on || start_on) ? (text_rgb[11:8]) :  // Red text (RGB: 1111)                                                        
                   (border) ? 4'hF :  // Yellow borders (RGB: 1111 0011)                                                           
                   (p_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)   assign vga_g = (video_on) ?                               
                   (o_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)               ((ball_on) ? 4'h0 :  // Fuchsia for ball (no g
                   (n_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)               (pad1_on) ? 4'hF :  // Green for left paddle (
                   (g_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)               (pad2_on) ? 4'h3 :  // Purple for right paddle
                   4'h0)  // Black background (RGB: 0000)               (score_on) ? (text_rgb[7:4]) : 4'h0)  // Red text (RGB: 111
                   : 4'h0; // Black background when video is off               : 4'h0; // Black background when video is off       
                                                                                                                                                                                                                                                                                                                                                                                         
    assign vga_g = (video_on) ?                                                                                                    
                   ((ball_on) ? 4'h0 :  // Fuchsia for ball                                                   
                   (pad1_on) ? 4'hF :  // Green for left paddle (RGB: 1111)                                                        
                   (pad2_on) ? 4'h3 :  // Purple for right paddle (RGB: 0011)                                                      
                   (score_on || game_over_on || player_win_on || start_on) ? (text_rgb[7:4]):  // Red text (RGB: 1111)                                                         
                   (border) ? 4'hF :  // Yellow borders (RGB: 1111 0011)                                                           
                   (p_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)                                                             
                   (o_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)                                                             
                   (n_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)                                                             
                   (g_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)                                                             
                   4'h0)  // Black background (RGB: 0000)                                                                          
                   : 4'h0; // Black background when video is off                                                                   
                                                                                                                                   
    assign vga_b = (video_on) ?                                                                                                    
                   ((ball_on) ? 4'hF :  // Fuchsia for ball (RGB: 1111)                                                            
                   (pad1_on) ? 4'h0 :  // Green for left paddle (no blue)                                                          
                   (pad2_on) ? 4'hF :  // Purple for right paddle (RGB: 1111)                                                      
                   (score_on || game_over_on || player_win_on || start_on) ? (text_rgb[3:0]) :  // Red text (RGB: 1111)                                                         
                   (border) ? 4'h3 :  // Yellow borders (RGB: 1111 0011)                                                           
                   (p_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)                                                             
                   (o_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)                                                             
                   (n_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)                                                             
                   (g_pixel) ? 4'hF :  // White pixel (RGB: 1111 1111)                                                             
                   4'h0)  // Black background (RGB: 0000)                                                                          
                   : 4'h0; // Black background when video is off  
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
                an = 4'b1011;       // Enable next display (Player 2's digit)
                segments = seg_Player2; // Assign Player 2's score
            end
            default: begin
                an = 4'b1111;       // Disable all displays
                segments = 7'b1111111; // Turn off all segments
            end
        endcase
    end

    endmodule