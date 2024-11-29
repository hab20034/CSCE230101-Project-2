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
    input clk,  
    input reset,    
    input up1,
    input down1,
    input up2,
    input down2,
    input video_on,
    input [9:0] x,
    input [9:0] y,
    output reg [11:0] rgb,
    output reg score1, score2
    );
    
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    
    localparam BORDER_THICKNESS = 5;
    // Border logic: Active at the edges of the display
    wire border;
    assign border = (x < BORDER_THICKNESS || x >= 640 - BORDER_THICKNESS || y < BORDER_THICKNESS || y >= 480 - BORDER_THICKNESS);
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
        // maximum x, y values in display area
        
        // PADDLE
        // paddle horizontal boundaries
        parameter X_PAD1_L = 40;
        parameter X_PAD1_R = 43;    // 4 pixels wide
        parameter X_PAD2_L = 600;
        parameter X_PAD2_R = 603;    // 4 pixels wide
        // paddle vertical boundary signals
        wire [9:0] y_pad1_t, y_pad1_b, y_pad2_t, y_pad2_b;
        parameter PAD_HEIGHT = 90;  // 90 pixels high
        // register to track top boundary and buffer
        reg [9:0] y_pad1_reg, y_pad1_next, y_pad2_reg, y_pad2_next;
        // paddle moving velocity when a button is pressed
        parameter PAD_VELOCITY = 2;     // change to speed up or slow down paddle movement
        
        // BALL
        // square rom boundaries
        parameter BALL_SIZE = 8;
        // ball horizontal boundary signals
        wire [9:0] x_ball_l, x_ball_r;
        // ball vertical boundary signals
        wire [9:0] y_ball_t, y_ball_b;
        // register to track top left position
        reg [9:0] y_ball_reg, x_ball_reg;
        // signals for register buffer
        wire [9:0] y_ball_next, x_ball_next;
        // registers to track ball speed and buffers
        reg [9:0] x_delta_reg, x_delta_next;
        reg [9:0] y_delta_reg, y_delta_next;
        // positive or negative ball velocity
        parameter BALL_VELOCITY_POS = 1;
        parameter BALL_VELOCITY_NEG = -1;
        // round ball from square image
        wire [2:0] rom_addr, rom_col;   // 3-bit rom address and rom column
        reg [7:0] rom_data;             // data at current rom address
        wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
        
        parameter BALL_CENTER_X = 320; // Middle of the screen
        parameter BALL_CENTER_Y = 240; // Middle of the screen
        
        // Register Control
        always @(posedge clk or posedge reset)
            if(reset) begin
                y_pad1_reg <= 0;
                y_pad2_reg <= 0;
                x_ball_reg <= BALL_CENTER_X;
                y_ball_reg <= BALL_CENTER_Y;
                x_delta_reg <= 10'h002;
                y_delta_reg <= 10'h002;
                score1 <= 0; // Reset scores
                score2 <= 0; // Reset scores
            end
            else begin
                y_pad1_reg <= y_pad1_next;
                y_pad2_reg <= y_pad2_next;
                x_ball_reg <= x_ball_next;
                y_ball_reg <= y_ball_next;
                x_delta_reg <= x_delta_next;
                y_delta_reg <= y_delta_next;
            end
        
        // ball rom
        always @*
            case(rom_addr)
                3'b000 :    rom_data = 8'b00111100; //   ****  
                3'b001 :    rom_data = 8'b01111110; //  ******
                3'b010 :    rom_data = 8'b11111111; // ********
                3'b011 :    rom_data = 8'b11111111; // ********
                3'b100 :    rom_data = 8'b11111111; // ********
                3'b101 :    rom_data = 8'b11111111; // ********
                3'b110 :    rom_data = 8'b01111110; //  ******
                3'b111 :    rom_data = 8'b00111100; //   ****
            endcase
        
        // OBJECT STATUS SIGNALS
        wire pad1_on, pad2_on, sq_ball_on, ball_on;
        
        // paddle 
        assign y_pad1_t = y_pad1_reg;
        assign y_pad2_t = y_pad2_reg;                               // paddle top position
        assign y_pad1_b = y_pad1_t + PAD_HEIGHT - 1;              // paddle bottom position
        assign y_pad2_b = y_pad2_t + PAD_HEIGHT - 1;              // paddle bottom position
        assign pad1_on = (X_PAD1_L <= x) && (x <= X_PAD1_R) &&     // pixel within paddle boundaries
                        (y_pad1_t <= y) && (y <= y_pad1_b);
        assign pad2_on = (X_PAD2_L <= x) && (x <= X_PAD2_R) &&     // pixel within paddle boundaries
                (y_pad2_t <= y) && (y <= y_pad2_b);
                        
        // Paddle Control
        always @* begin
            y_pad1_next = y_pad1_reg;
            y_pad2_next = y_pad2_reg;      // no move
            if(refresh_tick) begin
                if(up1 & (y_pad1_t > PAD_VELOCITY))
                    y_pad1_next = y_pad1_reg - PAD_VELOCITY;  // move up
                else if(down1 & (y_pad1_b < (Y_MAX - PAD_VELOCITY)))
                    y_pad1_next = y_pad1_reg + PAD_VELOCITY;  // move down
                    
                if(up2 & (y_pad2_t > PAD_VELOCITY))
                    y_pad2_next = y_pad2_reg - PAD_VELOCITY;  // move up
                else if(down2 & (y_pad2_b < (Y_MAX - PAD_VELOCITY)))
                    y_pad2_next = y_pad2_reg + PAD_VELOCITY;  // move down
            end
        end
        
        // rom data square boundaries
        assign x_ball_l = x_ball_reg;
        assign y_ball_t = y_ball_reg;
        assign x_ball_r = x_ball_l + BALL_SIZE - 1;
        assign y_ball_b = y_ball_t + BALL_SIZE - 1;
        // pixel within rom square boundaries
        assign sq_ball_on = (x_ball_l <= x) && (x <= x_ball_r) &&
                            (y_ball_t <= y) && (y <= y_ball_b);
        // map current pixel location to rom addr/col
        assign rom_addr = y[2:0] - y_ball_t[2:0];   // 3-bit address
        assign rom_col = x[2:0] - x_ball_l[2:0];    // 3-bit column index
        assign rom_bit = rom_data[rom_col];         // 1-bit signal rom data by column
        // pixel within round ball
        assign ball_on = sq_ball_on & rom_bit;      // within square boundaries AND rom data bit == 1
        // new ball position
        assign x_ball_next = (refresh_tick) ? x_ball_reg + x_delta_reg : x_ball_reg;
        assign y_ball_next = (refresh_tick) ? y_ball_reg + y_delta_reg : y_ball_reg;
        
        // change ball direction after collision
        always @* begin
            x_delta_next = x_delta_reg;
            y_delta_next = y_delta_reg;
            if(y_ball_t < 1)                                            // collide with top
                y_delta_next = BALL_VELOCITY_POS;                       // move down
            else if(y_ball_b > Y_MAX)                                   // collide with bottom
                y_delta_next = BALL_VELOCITY_NEG;                       // move up
            else if(x_ball_l <= BORDER_THICKNESS) begin                       // collide with wall 
                x_delta_next = BALL_VELOCITY_POS;
                score2 <= score2 +1; 
                end                      // move right
            else if(x_ball_l >= 640 - BORDER_THICKNESS) begin                               // collide with wall 
                x_delta_next = BALL_VELOCITY_NEG;
                score1 <= score1 +1; 
                end                       // move right 
            else if((X_PAD1_L <= x_ball_r) && (x_ball_r <= X_PAD1_R) &&
                    (y_pad1_t <= y_ball_b) && (y_ball_t <= y_pad1_b))   // collide with paddle
                x_delta_next = BALL_VELOCITY_POS;                       // move right
            else if((X_PAD2_L <= x_ball_r) && (x_ball_r <= X_PAD2_R) &&
                    (y_pad2_t <= y_ball_b) && (y_ball_t <= y_pad2_b))     // collide with paddle
                x_delta_next = BALL_VELOCITY_NEG;                       // move left
        end  
    always @* begin
       if (~video_on)
           rgb = 12'h000; // Black background
       else if (border)
           rgb = 12'hFF0; // Yellow border
       else if(pad1_on)
           rgb = 12'h6A2;      // paddle color
       else if(pad2_on)
           rgb = 12'hA5C;      // paddle color
       else if(ball_on)
           rgb = 12'hF0F;     // ball color
       else if (p_pixel || o_pixel || n_pixel || g_pixel)
           rgb = 12'hFFF; // White text
       else
           rgb = 12'h111; // Dim background
   end
                   
endmodule
