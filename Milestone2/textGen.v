
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
    //output [3:0] text_on,
    output reg [11:0] text_rgb,
    output  score_on
    );
    
    // signal declaration
    wire [10:0] rom_addr;
    reg [6:0] char_addr, char_addr_s, char_addr_l, char_addr_r, char_addr_o;
    reg [3:0] row_addr;
    wire [3:0] row_addr_s, row_addr_l, row_addr_r, row_addr_o;
    reg [2:0] bit_addr;
    wire [2:0] bit_addr_s, bit_addr_l, bit_addr_r, bit_addr_o;
    wire [7:0] ascii_word;
    wire ascii_bit, logo_on, rule_on, over_on;
    wire [7:0] rule_rom_addr;
    
   // instantiate ascii rom
   asciiRom ascii_unit(.clk(clk), .addr(rom_addr), .data(ascii_word));
   
   // ---------------------------------------------------------------------------
   // score region
   // - display two-digit score and ball # on top left
   // - scale to 16 by 32 text size
   // - line 1, 16 chars: "Score: dd Ball: d"
   // ---------------------------------------------------------------------------
   assign score_on = (y >= 40) && (y < 72) && (x >= 242) && (x < 498);

   //assign score_on = (y[9:5] == 0) && (x[9:4] < 16);
   assign row_addr_s = (y - 40) >> 1;
assign bit_addr_s = x[3:1];
always @* begin
    case((x - 242) >> 4) // Adjust horizontal character selection
        4'h0 : char_addr_s = 7'h53;     // S
        4'h1 : char_addr_s = 7'h43;     // C
        4'h2 : char_addr_s = 7'h4F;     // O
        4'h3 : char_addr_s = 7'h52;     // R
        4'h4 : char_addr_s = 7'h45;     // E
        4'h5 : char_addr_s = 7'h3A;     // :
        4'h6 : char_addr_s = {3'b011, dig1};    // tens digit
        4'h7 : char_addr_s = {3'b011, dig0};    // ones digit
        default: char_addr_s = 7'h00; // Blank
    endcase
end

    
     always @* begin
        text_rgb = 12'h000;     // aqua background
        
        if(score_on) begin
            char_addr = char_addr_s;
            row_addr = row_addr_s;
            bit_addr = bit_addr_s;
            if(ascii_bit)
                text_rgb = 12'hF00; // red
        end
      end 
    // ascii ROM interface
    assign rom_addr = {char_addr, row_addr};
    assign ascii_bit = ascii_word[~bit_addr];
endmodule
