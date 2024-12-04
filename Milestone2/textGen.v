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
    output score_on
    );
    
    // signal declaration
    wire [10:0] rom_addr;
    reg [6:0] charAddr, charAddrS, charAddrI, charAddrR, charAddrO;
    reg [3:0] rowAddr;
    wire [3:0] rowAddrS, rowAddrI, rowAddrR, rowAddrO;
    reg [2:0] bit_addr;
    wire [2:0] bit_addr_s, bit_addr_l, bit_addr_r, bit_addr_o;
    wire [7:0] ascii_word;
    wire ascii_bit, logo_on, rule_on, over_on;
    wire [7:0] rule_rom_addr;
    
   // instantiate ascii rom
   asciiRom ascii_unit(.clk(clk), .add(rom_addr), .data(ascii_word));
   // score region
   assign score_on = (state==2'b00)?(y >= 40) && (y < 72) && (x >= 240) && (x < 496):(y >= 0) && (y < 0) && (x >= 0) && (x < 0);
   assign rowAddrS = (y - 40) >> 1;
   assign bit_addr_s = x[3:1];
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

    
    always @* begin
        text_rgb = 12'h000;  
        
        if(score_on) begin
            charAddr = charAddrS;
            rowAddr = rowAddrS;
            bit_addr = bit_addr_s;
            if(ascii_bit)
                text_rgb = 12'hF00; 
        end
    end 
    // ascii ROM interface
    assign rom_addr = {charAddr, rowAddr};
    assign ascii_bit = ascii_word[~bit_addr];
endmodule
