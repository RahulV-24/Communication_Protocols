module BIST(
    input wire clk,
    //input wire in_data,
     input wire reset, 

    output wire S_cs, 
    output wire  S_s_clk,
    output wire[7:0] data_out,
    output wire [3:0] counter,
    output wire [2:0] Code,
    output wire [7:0] L_data
);
//wire [7:0] L_data;

LFSR V0(clk, reset, L_data);
spi_master V1 (L_data,reset, clk, S_cs, S_s_clk, data_out, counter);
Cmp V2 (S_s_clk, L_data, data_out, Code);



endmodule






module LFSR(
    input wire clk,
    input wire reset,
    output wire[7:0] data_out
);
reg [7:0] out = 8'h00;
reg [2:0] count=3'd7;
wire w_xor;
assign w_xor = out[7] ^ out[1];

always @(posedge clk)
begin
    if(reset)
        begin
            out <= 8'h10;
        end
    else
   // while (count>=0) 
     //   begin
       //   out[count]<= out[count-1];
         // count <= count-1;
         // if(count==0)
          //  out[count] <= w_xor; 
        //end 
        
        
        out <= {out[6],out[5],out[4],out[3],out[2],out[1],out[0],w_xor}; 
        #42;
end
assign data_out = out;

endmodule
//SPI Module

module spi_master(

    input wire [7:0] in_data,
    input wire reset,
    input wire clk,        //system clock
    //input reset_n;
    //input go;

    output wire S_cs, 
    output wire  S_s_clk,
    output wire  [7:0] data_out,
    output wire [3:0] counter
    
);

//reg BIST_MODE = 0;
//reg GO;
reg [7:0] MOSI;   //shift register
reg cs;            // control chip select   when cs is low(i.e., 0)it transfers data to that slave
reg s_clk;          // spi clock
reg [1:0] state;
reg [3:0] count;

//for normal mode and BIST mode....if BIST MODE==1 then BIST mode is on
//always @(reset_n) 
//begin
    //if(reset_n==1)
     //   BIST_MODE = 1;
   // else 
  //      BIST_MODE = 0;
    
//end

//always @(go) 
//begin
 //   if(go==1)

    
//end 

always @(posedge clk or posedge reset) 
begin
    if(reset)
        begin
            MOSI <= 8'b0;
            count <= 4'd0;
            cs <= 1'b1;
            s_clk <= 1'b0;
        end
      
else 
    begin
      case(state)
        0: begin
          s_clk <= 1'b0;
          cs <=1'b1;
          state <=1;
        end

        1: begin
          s_clk <= 1'b0;
          cs <= 1'b0;
          MOSI <= {MOSI[6:0],in_data};
          count <= count-1;
          state <=2;
        end 

        2:begin
          s_clk <=1'b1;
            if (count>0)
                state <= 1;
            else begin
                count <= 8;
                state <=0;
                end
        end
        default :state <=0; 
      endcase
end
end
assign S_cs = cs;
assign S_s_clk = s_clk;
assign data_out = MOSI;
assign counter = count;

endmodule   

module Cmp(
    input wire clk,
    input wire [7:0] L_data,
    input wire [7:0] S_data,

    output wire [2:0] Code
);

reg [2:0] code;

always @(negedge clk)
    begin
      if(L_data == S_data)
             code = 3'b101;
        else
             code = 3'b001;
    end

    assign Code = code;

endmodule
