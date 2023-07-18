`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2023 08:25:52
// Design Name: 
// Module Name: BIST
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

//SPI Master Module

module spi_master(

    input wire [7:0] in_data,
    input wire MISO_in_data,
    input wire reset,
    input wire clk,        //system clock
    input wire master_writeread,        //1 for write and 0 for read

    output wire CS, 
    output wire  MOSI_data_out,
    output wire [3:0] counter,
    output wire [7:0] MISO_data
    
);

reg [7:0] master_MOSI;  //master_MISO shift register
reg cs;            // control chip select   when cs is low(i.e., 0)it transfers data to that slave
reg  master_MOSI_state;
reg  master_MISO_state;
reg [3:0] master_MOSI_count;
reg [3:0] master_MISO_count;
reg [7:0] master_MISO_out_data;
reg [7:0] master_MISO;
reg out;
  
always@(posedge clk or posedge reset)
    begin
 
        if(reset)
            begin
                
                cs <= 1'b1;
                master_MOSI_state <= 1'b0;
            end
        else 
            begin
                case(master_MOSI_state)
                    0:             //state 0
                            begin
                                cs <=1'b0;
                                master_MOSI_state <= 1;
                                master_MOSI_count <= 4'd8;
                                master_MOSI= in_data;
                            end
                      

                    1: begin                 //state 1
                        if(cs==0 && master_MOSI_count>0)
                            begin
                                out = master_MOSI[0];          //master_MOSI data out which would go in SLAVE
                                master_MOSI = master_MOSI >> 1;
                                master_MOSI_count <= master_MOSI_count-1;
                            end
                        else
                            begin
                                cs =1'b0;
                                master_MOSI_state = 0;
                            end
                        end 

                    default :master_MOSI_state <= 0; 
                endcase
            end
   end

   
   always@(posedge clk or posedge reset)
    begin

        if(reset)
            begin
                master_MISO_count <= 4'd0;
                cs <= 1'b1;
                master_MISO_state <=1'b0;
            end
      
        else 
            begin
                case(master_MISO_state)
                    0:           //state 0
                       begin
                                cs <=1'b0;
                                master_MISO_state <= 1;
                                master_MISO =8'd0;
                                master_MISO_count = 4'd8;
                            
                        end

                    1: begin                 //state 1
                        if(master_MISO_count>=0)
                            begin
                                master_MISO = {MISO_in_data,master_MISO[7:1]};                      // data in of MASTER from master_MISO pin
                                master_MISO_count <= master_MISO_count-1;
                            end
                        if(master_MISO_count==0)
                            begin
                                cs =1'b0;
                                master_MISO_state <= 0;
                            end
                        end 

                    default :master_MISO_state <= 0; 
                endcase
           
            
            if(master_MISO_count == 0)
             begin
                master_MISO_out_data = master_MISO;
             end
           end  
   end

   
assign CS = cs;
assign MOSI_data_out = out;
assign counter = master_MOSI_count;
assign MISO_data = master_MISO_out_data;

endmodule   
