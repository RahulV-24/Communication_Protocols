`include "SPI_BIST.v"

module BIST_tb;

    reg clk;
    reg reset; 
    reg master_writeread;
    reg [7:0] MOSI_user_input;
    reg[7:0] MISO_user_input;
    reg select;
    
    wire CS; 
    wire S_clk;
    wire [3:0] counter;
    wire MOSI_res;
    wire MISO_res; 
    wire [7:0] BIST_output;

BIST dut(
  .clk(clk),
  .reset(reset),
  .master_writeread(master_writeread),
  .MOSI_user_input(MOSI_user_input),
  .MISO_user_input(MISO_user_input),
  .select(select),
  .CS(CS),
  .S_clk(S_clk),
  .counter(counter),
  .MOSI_res(MOSI_res),
  .MISO_res(MISO_res),
  .BIST_output(BIST_output)
);

initial 
  begin
  clk = 0;
  reset = 1;
  master_writeread=1;
  select = 1;
  MOSI_user_input = 8'hf0;
  MISO_user_input = 8'hf0;
end

always #10 clk= ~clk;

  initial
   begin
     $dumpfile("output2.vcd");
     $dumpvars;
   end
  
initial begin
   #20 reset =1'b0;
  
end
initial begin
  #1000 $finish;
end

endmodule
end

endmodule
