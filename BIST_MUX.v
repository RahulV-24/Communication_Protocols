`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2023 17:19:33
// Design Name: 
// Module Name: BIST_MUX
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


module BIST_MUX(
    input wire [7:0] user_input,
    input wire [7:0] BIST_input,
    input wire select,                  //1 for BIST 0 for user input
    output wire [7:0] out

    );
  reg [7:0] out_temp;
  
  always@(*)
  begin
        if(select ==0)
            out_temp = user_input;
        else
            out_temp = BIST_input;
  end
  assign out = out_temp;
    
endmodule
