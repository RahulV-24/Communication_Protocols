
`include "SPI_BIST.v"

module BIST_tb;

    reg clk;
    reg reset; 

    wire S_cs; 
    wire S_s_clk;
    wire[7:0] data_out;
    wire [3:0] counter;
    wire [2:0] Code;
    wire [7:0] L_data;

BIST dut(
  .clk(clk),
  .reset(reset),
  .S_cs(S_cs),
  .S_s_clk(S_s_clk),
  .data_out(data_out),
  .counter(counter),
  .Code(Code),
  .L_data(L_data)
);

initial 
  begin
  clk = 0;
  reset = 1;
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
