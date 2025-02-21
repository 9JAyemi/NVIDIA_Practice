module fifo #(parameter DEPTH = 7, DATA_WIDTH = 8) (
    input clk,
    input rst_n,
    input w_en,
    input [DATA_WIDTH - 1 : 0] data_in,
    input r_en,
    output full,
    output reg [DATA_WIDTH - 1 : 0] data_out,
    output empty

);

reg [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
reg [DATA_WIDTH-1:0] fifo[DEPTH]; 
reg [$clog2(DEPTH)-1:0] count;

always @(posedge clk) begin
    //default values
if(!rst_n) begin
    w_ptr <= 0;
    r_ptr <= 0;
    data_out <= 0;
    count <= 0;
end
else begin
      case({(w_en & !full),(r_en & !empty)})
        2'b00, 2'b11: count <= count;
        2'b01: count <= count - 1'b1;
        2'b10: count <= count + 1'b1;
      endcase
    end
end

//To write data to FIFO
always @(posedge clk) begin
    if(w_en & !full) begin
        fifo[w_ptr] <= data_in;
        if(w_ptr < DEPTH) begin
        w_ptr <= w_ptr + 1;
        end

end
end

//To read data to FIFO
always @(posedge clk) begin
    if(r_en & !empty) begin
        data_out <= fifo[r_ptr];
        r_ptr <= r_ptr + 1;
end
end

assign full = (count== DEPTH);
assign empty = (count == 0);

endmodule