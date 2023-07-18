module BIST(
    input wire clk,
     input wire reset, 
     input wire master_writeread,
    input wire [7:0] MOSI_user_input,
    input wire [7:0] MISO_user_input,
    input wire select,
    output wire CS, 
    output wire  S_clk,
    output wire [3:0] counter,
    output wire MOSI_res,
    output wire MISO_res,
    output wire [7:0] BIST_output
);

wire   MOSI_data_out;
wire  MISO_data_out;
wire [7:0] MOSI_data;
wire [7:0] MISO_data;

wire [7:0] BIST_mode_mux_out;

wire [4:0] count;
wire [7:0] MOSI_out;   ///MUX input MOSI side
wire [7:0] MISO_out;   //MUX input MISO side
wire [7:0] LFSR_out;

BIST_MUX M1(MOSI_user_input,LFSR_out,select,MOSI_out);
BIST_MUX M2(MISO_user_input,LFSR_out,select,MISO_out);

LFSR V0(clk, reset,LFSR_out,count);
spi_master V1 (MOSI_out,MISO_data_out,reset, clk, master_writeread, CS, S_clk, MOSI_data_out, counter,MISO_data);
spi_slave V2 (clk,reset,MOSI_data_out,master_writeread,MISO_out,MISO_data_out,MOSI_data);
Cmp V3 (clk,select,count,LFSR_out,MOSI_data,LFSR_out,MISO_data,MOSI_res,MISO_res);

assign BIST_output = LFSR_out;


endmodule


module LFSR(
    input wire clk,
    input wire reset,
    output wire[7:0] data_out,
    output wire[4:0] count
);
reg [7:0] shiftreg = 8'h00;
reg xor1,xor2,xor3;
reg [4:0] counter;

always @(posedge clk)
begin

    if(reset)
        begin
            shiftreg <= 8'hF0;
            counter <=4'd9;
        end
    else
         begin
         if(counter == 0)
            begin
            xor1 = shiftreg[7]^shiftreg[5];
            xor2 = xor1^shiftreg[4];
            xor3 = xor2^shiftreg[3];
            shiftreg = {shiftreg[6:0],xor3};
            counter<=4'd9;
            end
         end
         counter = counter-1;
end

assign data_out = shiftreg;
assign count = counter;

endmodule



module Cmp(
    input wire clk,
    input wire select,
    input wire [4:0] count,
    input wire [7:0] MOSI_in_data,
    input wire [7:0] MOSI_out_data,
    input wire [7:0] MISO_in_data,
    input wire [7:0] MISO_out_data,

    output wire  MOSI_result,
    output wire  MISO_result
);

reg MOSI_res;
reg MISO_res;
    reg [7:0] MOSI_in_data_reg;
    reg [7:0] MOSI_out_data_reg;
    reg  [7:0] MISO_in_data_reg;
    reg  [7:0] MISO_out_data_reg;

always @(posedge clk)
begin
    if(select == 1)
  begin
    if(count == 0)
    begin
        MOSI_in_data_reg = MOSI_in_data;
        MISO_in_data_reg = MISO_in_data;
        
    end
 
    if(count == 9)
    begin
        MOSI_out_data_reg = MOSI_out_data;
        MISO_out_data_reg = MISO_out_data;
        
    end  
    
      if(MOSI_in_data_reg == MOSI_out_data_reg)
             MOSI_res=1'd1;
        else
             MOSI_res = 1'd0;
             
       if(MISO_in_data_reg == MISO_out_data_reg)
             MISO_res=1'd1;
        else
             MISO_res = 1'd0;
    end
end
    assign MISO_result  = MISO_res;
    assign MOSI_result = MOSI_res;
  
endmodule

