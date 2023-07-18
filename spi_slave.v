`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2023 11:37:28
// Design Name: 
// Module Name: spi_slave
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


//SPI SLave Module

module spi_slave(

input wire  clk,
input wire  reset,
input wire  MOSI_in_data,
input wire master_writeread,        //1 for read and 0 for write
inout wire [7:0] slave_in_data,
output wire MISO_data_out,
output wire [7:0] MOSI_data
);

reg [7:0] slave_MOSI;  //slave_MISO shift register
reg [7:0] slave_MOSI_out;
reg cs;            // control chip select   when cs is low(i.e., 0)it transfers data to that slave
reg  slave_MOSI_state;
reg  slave_MISO_state;
reg [3:0] slave_MOSI_count;
reg [3:0] slave_MISO_count;

always@(posedge clk or posedge reset)
     begin
        if(reset)
            begin
                slave_MOSI_count <= 4'd0;
                cs <= 1'b1;
                slave_MOSI_state <=1'b0;
            end
      
        else 
            begin
                case(slave_MOSI_state)
                    0:            //state 0
                            begin
                                cs <=1'b0;
                                slave_MOSI_state <= 1;
                                 slave_MOSI_count <= 4'd8;
                                 slave_MOSI= 8'd0;
                            end
               

                    1: begin                 //state 1
                        if(slave_MOSI_count>=0)
                            begin
                               slave_MOSI = {MOSI_in_data,slave_MOSI[7:1]}; // data in of slave from slave_MOSI pin
                                slave_MOSI_count <= slave_MOSI_count-1;
                            end
                         if(slave_MOSI_count == 0)
                            begin
                                cs =1'b0;
                                slave_MOSI_state <= 0;
                            end
                        end 

                    default :slave_MOSI_state <= 0; 
                endcase
           
           if(slave_MOSI_count == 0)
             begin
                slave_MOSI_out = slave_MOSI;
             end
            end
   end
   // slave_MISO shift register  communication from slave to master
   reg [7:0] slave_MISO;
   reg out;
   
   
always@(posedge clk or posedge reset)
     begin
        if(reset)
            begin
                // slave_MOSI <= 8'b0;
                slave_MISO_state <= 1'b0;
                cs <= 1'b1;
            end
      
        else 
            begin
                case(slave_MISO_state)
                    0:           //state 0
                            begin
                                cs <=1'b0;
                                slave_MISO_state <= 1;
                                 slave_MISO_count <= 4'd8;
                                slave_MISO = slave_in_data;
                            end

                    1: begin                 //state 1
                        if(cs==0 && slave_MISO_count>0)
                            begin
                                out <= slave_MISO[0];          //slave_MISO data out which would go in MASTER
                                slave_MISO <= slave_MISO >> 1;
                                slave_MISO_count <= slave_MISO_count-1;
                            end
                        else
                            begin
                                cs =1'b0;
                                slave_MISO_state <= 0;
                            end
                        end 

                    default :slave_MISO_state <= 0; 
                endcase
            end
   end
assign MISO_data_out = out;
assign MOSI_data = slave_MOSI_out;  
endmodule