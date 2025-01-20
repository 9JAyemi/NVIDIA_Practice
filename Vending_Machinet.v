//Testbench

module Vending_Machine_tb();

reg clk,R,D,Q,I,N,A,B,C;

wire A_o,B_o,C_o;
wire [6:0]Total_Amount;

Vending_Machine DUT (A_o,B_o,C_o,Total_Amount,clk,R,A,B,C,D,Q,I,N);

initial
begin
R = 1;
#75 R = 0;
#575 R = 1;

end

initial
begin
clk = 1;
forever #50 clk = ~clk;
end


initial
begin
N = 0;
#120 N = 1'b1;
#10 N = 1'b0;
end


initial
begin
Q = 0;
#220 Q = 1'b1;
#10 Q = 1'b0;
#125 Q = 1'b1;
#10 Q = 1'b0;
end


initial
begin
I = 0;
#430 I = 1'b1;
#25 I = 1'b0;
#85 I = 1'b1;
#10 I = 1'b0;
#60 I = 1'b1;
#10 I = 1'b0;
end


initial
begin
D = 0;
end


initial
begin
A = 0;
#590 A = 1'b1;
end

initial
begin
B = 0;
end

initial
begin
C = 0;
end


endmodule