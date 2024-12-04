`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 07:24:59 PM
// Design Name: 
// Module Name: textGen
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


module textGen(
    input clk,
    input [1:0] ball,
    input [3:0] dig0, dig1,
    input [9:0] x, y,
    input [1:0] state,
    output reg [11:0] text_rgb,
    output score_on,
    output game_over_on,
    output player_win_on,
    output start_on
    );
    
    // signal declaration
    wire [10:0] rom_addr;
    reg [6:0] charAddr, charAddrS , charAddrG, charAddrWin, charAddrStart;
    reg [3:0] rowAddr;
    wire [3:0] rowAddrS, rowAddrG, rowAddrWin, rowAddrStart;
    reg [2:0] bit_addr;
    wire [2:0] bit_addr_s, bit_addr_g, bit_addr_win, bit_addr_start;
    wire [7:0] ascii_word;
    wire ascii_bit, logo_on, rule_on, over_on;
    wire [7:0] rule_rom_addr;
   // instantiate ascii rom
   asciiRom ascii_unit(.clk(clk), .add(rom_addr), .data(ascii_word));
   // score region
   assign start_on = (state == 2'b00) && (y >= 100) && (y < 140) && (x >= 240) && (x < 622); 
   assign score_on = (state==2'b01) && (y >= 40) && (y < 72) && (x >= 240) && (x < 496); //:(y >= 0) && (y < 0) && (x >= 0) && (x < 0);
   assign game_over_on = (state== 2'b10) && (y>=100) && (y<140) && (x>=240) && (x<622);
   assign player_win_on = (state== 2'b10) && (y>=130) && (y<152) && (x>=240) && (x<622);
   assign rowAddrS = (y - 40) >> 1;
   assign bit_addr_s = x[3:1];
   assign rowAddrG = (y-100) >>1;
   assign bit_addr_g = x[3:1];
   assign rowAddrWin = (y-130) >>1;
   assign bit_addr_win = x[3:1];
   assign rowAddrStart = (y-100) >> 1;
   assign bit_addr_start = x[3:1];
   always @* begin
       case((x - 240) >> 4) // Adjust horizontal character selection
           4'h0 : charAddrS = 7'h53;     
           4'h1 : charAddrS = 7'h43;     
           4'h2 : charAddrS = 7'h4F;     
           4'h3 : charAddrS = 7'h52;    
           4'h4 : charAddrS = 7'h45;     
           4'h5 : charAddrS = 7'h3A;     
           4'h6 : charAddrS = {3'b011, dig1};    
           4'h7 : charAddrS = {3'b011, dig0};    
           default: charAddrS = 7'h00; 
       endcase
   end
   always @ * begin
if((x >= 240) && (x < 622)) begin
       case((x - 240) >> 4) // Adjust horizontal character selection
           4'h0 : charAddrG = 7'h47;     // G
           4'h1 : charAddrG = 7'h41;     // A
           4'h2 : charAddrG = 7'h4D;     // M
           4'h3 : charAddrG = 7'h45;     // E
           4'h4 : charAddrG = 7'h00;     // (space or empty)
           4'h5 : charAddrG = 7'h4F;     // O
           4'h6 : charAddrG = 7'h56;     // V
           4'h7 : charAddrG = 7'h45;     // E
           4'h8 : charAddrG = 7'h52;     // R
           default: charAddrG = 7'h00;    // Default case if out of range
       endcase
   end
   else begin
   charAddrG = 7'h00;
    end
    end
    
    always @* begin
            // PLAYER 1 WINS / PLAYER 2 WINS text
            if ((x >= 240) && (x < 622)) begin
                case ((x - 240) >> 4)
                    4'h0 : charAddrWin = 7'h50;  // P
                    4'h1 : charAddrWin = 7'h4C;  // L
                    4'h2 : charAddrWin = 7'h41;  // A
                    4'h3 : charAddrWin = 7'h59;  // Y
                    4'h4 : charAddrWin = 7'h45;  // E
                    4'h5 : charAddrWin = 7'h52;  // R
                    4'h6 : charAddrWin = 7'h00;
                    4'h7 : charAddrWin = (dig0 == 4'hA) ? 7'h31 : 7'h32; // 1 for PLAYER 1, 2 for PLAYER 2
                    4'h8 : charAddrWin = 7'h00;     
                    4'h9 : charAddrWin = 7'h57;  // W
                    4'hA : charAddrWin = 7'h49;  // I
                    4'hB : charAddrWin = 7'h4E;  // N
                    4'hC : charAddrWin = 7'h53;  // S
                    default: charAddrWin = 7'h00;
                endcase
            end else begin
                charAddrWin = 7'h00;
            end
        end
        always @* begin
                if ((x>=240) && (x<622)) begin // Check if in the "Start" screen state
                    case((x - 240) >> 4) // Adjust horizontal character selection for "START"
                        4'h0 : charAddrStart = 7'h53;  // S
                        4'h1 : charAddrStart = 7'h54;  // T
                        4'h2 : charAddrStart = 7'h41;  // A
                        4'h3 : charAddrStart = 7'h52;  // R
                        4'h4 : charAddrStart = 7'h54;  // T
                        default: charAddrStart = 7'h00; // Default empty character
                    endcase
                end
               else begin
                        charAddrStart = 7'h00;
                        end
            end
    always @* begin
        text_rgb = 12'h000; // Default background color
            charAddr = 7'h00;
        rowAddr = 4'b0;
        bit_addr = 3'b0;
        if (start_on) begin
            charAddr = charAddrStart;
             rowAddr = rowAddrStart;
             bit_addr = bit_addr_start;
             if (ascii_bit)
            text_rgb = 12'hF00;
     end  else if (score_on) begin
            charAddr = charAddrS;
            rowAddr = rowAddrS;
            bit_addr = bit_addr_s;
            if (ascii_bit)
                text_rgb = 12'hF00; // Red
        end else if (game_over_on) begin
            charAddr = charAddrG;
            rowAddr = rowAddrG;
            bit_addr = bit_addr_g;
            if (ascii_bit)
                text_rgb = 12'h0F0; // Green
        end else if (player_win_on) begin
            charAddr = charAddrWin;
            rowAddr = rowAddrWin;
            bit_addr = bit_addr_win;
            if (ascii_bit)
                text_rgb = 12'h00F; // Blue for the win message
        end
    end
    // ascii ROM interface
    assign rom_addr = (start_on) ? {charAddrStart, rowAddrStart} : (player_win_on) ? {charAddrWin, rowAddrWin} : (game_over_on) ? {charAddrG, rowAddrG}: (score_on) ? {charAddrS, rowAddrS} : 11'b0;
    assign ascii_bit = ascii_word[~bit_addr];
endmodule