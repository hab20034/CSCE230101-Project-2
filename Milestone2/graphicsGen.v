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
    input [1:0] state,
    output reg [11:0] rgb,
    output reg [3:0] score1, score2,
    output border,pad1On, pad2On, ballOn,
    output p_pixel, o_pixel, n_pixel, g_pixel,
    output reg [1:0] winner
    );
    
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    wire refreshTick;
    assign refreshTick = ((y == 481) && (x == 0)) ? 1 : 0; // manage vsync
  //  reg [1:0] Winner1, Winner2;

    localparam BORDER_THICKNESS = 5;
    // Border logic: Active at the edges of the display
    //wire border;
    assign border = (x < BORDER_THICKNESS || x >= 640 - BORDER_THICKNESS || y < BORDER_THICKNESS || y >= 480 - BORDER_THICKNESS);
    //wire p_pixel, o_pixel, n_pixel, g_pixel;
    wire o_left, o_top, o_right, o_bottom;
    wire n_left, n_top, n_right;
    wire G_left, G_top, G_bottom, G_right, G_mid;
    //reg restart=0;
  //  reg [1:0] winner;
    
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
        
        // PADDLE
        // paddle horizontal boundaries
        parameter X_PAD1_L = 40;
        parameter X_PAD1_R = 43;
        parameter X_PAD2_L = 600;
        parameter X_PAD2_R = 603;
        // paddle vertical boundary signals
        wire [9:0] y_pad1_t, y_pad1_b, y_pad2_t, y_pad2_b;
        parameter padHeight = 90;  // 90 pixels high
        // register to track top boundary and buffer
        reg [9:0] y_pad1_reg, y_pad1_next, y_pad2_reg, y_pad2_next;
        // paddle moving velocity when a button is pressed
        parameter padVelocity = 2;  // velocity of paddles
        
        // square rom boundaries
        parameter ballSize = 8;

        // ball horizontal boundary signals
        wire [9:0] xBallL, xBallR;

        // ball vertical boundary signals
        wire [9:0] yBallT, yBallB;

        // register to track top left position
        reg [9:0] yBallReg, xBallReg;

        // signals for register buffer
        wire [9:0] yBallNext, xBallNext;

        // registers to track ball speed and buffers
        reg [9:0] xDeltaReg, xDeltaNext;
        reg [9:0] yDeltaReg, yDeltaNext;

        // positive or negative ball velocity
        parameter ballVelocityPositive = 1;
        parameter ballVelocityNegative = -1;

        // round ball from square image
        wire [2:0] romAddr, romCol;   // 3-bit rom address and rom column
        reg [7:0] romData; // data at current rom address
        wire romBit; // signify when rom data is 1 or 0 for ball rgb control
        
        parameter BALL_CENTER_X = 320;
        parameter BALL_CENTER_Y = 240;
        
        // Register Control
        always @(posedge clk or posedge reset)
            if(reset) begin
                y_pad1_reg <= 0;
                y_pad2_reg <= 0;
                xBallReg <= BALL_CENTER_X;
                yBallReg <= BALL_CENTER_Y;
                xDeltaReg <= 10'h002;
                yDeltaReg <= 10'h002;
                //restart <=0;
              //  score1 <= 0; // Reset scores
             //   score2 <= 0; // Reset scores
            end
            else begin
                y_pad1_reg <= y_pad1_next;
                y_pad2_reg <= y_pad2_next;
                xBallReg <= xBallNext;
                yBallReg <= yBallNext;
                xDeltaReg <= xDeltaNext;
                yDeltaReg <= yDeltaNext;
                
            /*  if (xBallL <= BORDER_THICKNESS) // Left wall collision
                            score2 <= score2 + 1;
                else if (xBallR >= 640 - BORDER_THICKNESS) // Right wall collision
                            score1 <= score1 + 1;*/
            end
 reg score_update_flag;
// Updating score and winner logic
 always @(posedge clk or posedge reset) begin
    if (reset) begin
        score1 <= 0;
        score2 <= 0;
        score_update_flag <= 0;
        winner <= 2'b00;  // No winner initially
    end else begin
        // Only update the winner if the game is ongoing
        if (score1 < 10 && score2 < 10) begin
            winner <= 2'b00; // Reset winner if no one has won yet
        end

        // Ball hits left or right wall and updates score
        if (xBallL <= BORDER_THICKNESS && !score_update_flag) begin
            score2 <= score2 + 1;
            score_update_flag <= 1;  // Prevent multiple increments for same event
        end else if (xBallR >= 640 - BORDER_THICKNESS && !score_update_flag) begin
            score1 <= score1 + 1;
            score_update_flag <= 1;  // Prevent multiple increments for same event
        end else if (xBallL > BORDER_THICKNESS && xBallR < 640 - BORDER_THICKNESS) begin
            score_update_flag <= 0;  // Reset flag when ball is not near walls
        end

        // Check if a player has won
        if (score1 >= 10) begin
            winner <= 2'b01;  // Player 1 wins
            score1 =0;
        end else if (score2 >= 10) begin
            winner <= 2'b10;  // Player 2 wins
            score2 = 0;
        end
    end
end

   // ball rom
always @*
 case(romAddr)
 3'b000 :    romData = 8'b00111100;
 3'b001 :    romData = 8'b01111110;
 3'b010 :    romData = 8'b11111111;
3'b011 :    romData = 8'b11111111;
3'b100 :    romData = 8'b11111111;
3'b101 :    romData = 8'b11111111;
 3'b110 :    romData = 8'b01111110;
3'b111 :    romData = 8'b00111100; 
 endcase
        
        // OBJECT STATUS SIGNALS
        wire sq_ballOn;
        
        // paddle 
        assign y_pad1_t =y_pad1_reg;
        assign y_pad2_t = y_pad2_reg; // paddle top position
        assign y_pad1_b = y_pad1_t + padHeight - 1; // paddle bottom position
        assign y_pad2_b = y_pad2_t + padHeight - 1; // paddle bottom position
        assign pad1On =  (state==2'b01)?((X_PAD1_L <= x) && (x <= X_PAD1_R) && (y_pad1_t <= y) && (y <= y_pad1_b)):((0 <= x) && (x <= 0) && (0 <= y) && (y <= 0));  // pixel within paddle boundaries
        assign pad2On = (state==2'b01)?((X_PAD2_L <= x) && (x <= X_PAD2_R) && (y_pad2_t <= y) && (y <= y_pad2_b)):((0 <= x) && (x <= 0) && (0 <= y) && (y <= 0));
      //  assign Win1 = Winner1;
      //  assign Win2 = Winner2;               
        // Paddle Control
        always @* begin
            y_pad1_next = y_pad1_reg;
            y_pad2_next = y_pad2_reg;      // no movement
            if(refreshTick) begin
                if(up1 & (y_pad1_t > padVelocity))
                    y_pad1_next = y_pad1_reg - padVelocity;  // move up
                else if(down1 & (y_pad1_b < (Y_MAX - padVelocity)))
                    y_pad1_next = y_pad1_reg + padVelocity;  // move down
                    
                if(up2 & (y_pad2_t > padVelocity))
                    y_pad2_next = y_pad2_reg - padVelocity;  // move up
                else if(down2 & (y_pad2_b < (Y_MAX - padVelocity)))
                    y_pad2_next = y_pad2_reg + padVelocity;  // move down
            end
        end
        
        // rom data square boundaries
        assign xBallL = xBallReg;
        assign yBallT = yBallReg;
        assign xBallR = xBallL + ballSize - 1;
        assign yBallB = yBallT + ballSize - 1;
        // pixel within rom square boundaries
        assign sq_ballOn = (state==2'b01)?((xBallL <= x) && (x <= xBallR) && (yBallT <= y) && (y <= yBallB)):((0 <= x) && (x <= 0) && (0 <= y) && (y <= 0));
        // map current pixel location to rom addr/col
        assign romAddr = y[2:0] - yBallT[2:0];   // 3-bit address
        assign romCol = x[2:0] - xBallL[2:0];    // 3-bit column index
        assign romBit = romData[romCol];         // 1-bit signal rom data by column
        // pixel within round ball
        assign ballOn = sq_ballOn & romBit;      // within square boundaries AND rom data bit == 1
        // new ball position
assign xBallNext = (state == 2'b01 && score1 < 10 && score2 < 10 && refreshTick) ? xBallReg + xDeltaReg : xBallReg;
assign yBallNext = (state == 2'b01 && score1 < 10 && score2 < 10 && refreshTick) ? yBallReg + yDeltaReg : yBallReg;
        // change ball direction after collision
        always @* begin
            xDeltaNext = xDeltaReg;
            yDeltaNext = yDeltaReg;
            if (state == 2'b01 && score1 < 10 && score2 < 10) begin
                    if (yBallT < 1) // collide with top border
                        yDeltaNext = ballVelocityPositive; // move down
                    else if (yBallB > Y_MAX) // collide with bottom border
                        yDeltaNext = ballVelocityNegative; // move up
                    else if (xBallL <= BORDER_THICKNESS) // collide with left wall
                        xDeltaNext = ballVelocityPositive; // move right
                    else if (xBallR >= 640 - BORDER_THICKNESS) // collide with right wall
                        xDeltaNext = ballVelocityNegative; // move left
                    else if ((X_PAD1_L <= xBallR) && (xBallR <= X_PAD1_R) && 
                             (y_pad1_t <= yBallB) && (yBallT <= y_pad1_b)) // paddle 1 collision
                        xDeltaNext = ballVelocityPositive; // move right
                    else if ((X_PAD2_L <= xBallR) && (xBallR <= X_PAD2_R) && 
                             (y_pad2_t <= yBallB) && (yBallT <= y_pad2_b)) // paddle 2 collision
                        xDeltaNext = ballVelocityNegative; // move left
                end
            end
    always @* begin
       if (~video_on)
           rgb = 12'h000; // Black background
       else if (border)
           rgb = 12'hFF0; // Yellow border
       else if(pad1On)
           rgb = 12'h6A2; // paddle1 color
       else if(pad2On)
           rgb = 12'hA5C; // paddle2 color
       else if(ballOn)
           rgb = 12'hF0F;  // ball color
       else if (p_pixel || o_pixel || n_pixel || g_pixel)
           rgb = 12'hFFF; // White text
       //else
           //rgb = 12'h111; // Dim background
   end
endmodule