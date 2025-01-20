module memory(
    `ifdef TAINT
    input addr_t,
    input data_in_t,
    input we_t,
    input in_valid_t,
    output data_out_t,
    output out_valid_t,
    output in_ready_t,
    `endif
    input clk,
    input rst,
    input [3:0] addr,
    input [7:0] data_in,
    input we,
    input in_valid,
    output [7:0] data_out,
    output out_valid,
    output in_ready
    );
reg [7:0] mem [0:15];
reg [7:0] data_buf;
reg [3:0] addr_buf;
reg we_buf;
reg busy;

`ifdef TAINT
reg [15:0] mem_t;
reg data_buf_t;
reg addr_buf_t;
reg we_buf_t;
reg busy_t;
`endif

assign data_out = mem[addr_buf];
assign out_valid = busy;
assign in_ready = ~busy;

`ifdef TAINT
assign data_out_t = mem_t[addr_buf] || addr_buf_t;
assign out_valid_t = busy_t;
assign in_ready_t = busy_t;
`endif

always @(posedge clk) begin
    busy <= in_valid && ~busy;
    we_buf <= in_valid && ~busy && we;
    data_buf <= 8*{in_valid && ~busy} & data_in;
    addr_buf <= 4*{in_valid && ~busy} & addr;
    mem[addr_buf] <= (busy && we_buf) ? data_buf : mem[addr_buf];
    
    `ifdef TAINT
    busy_t <= in_valid_t || busy_t;
    we_buf_t <= in_valid_t || busy_t || we_t;
    data_buf_t <= in_valid_t || busy_t || data_in_t;
    addr_buf_t <= in_valid_t || busy_t || addr_t;
    mem_t[addr_buf] <= busy_t || we_buf_t || data_buf_t || mem_t[addr_buf] || addr_buf_t;
    `endif
end



// Only for verification purpose, facilitate property writing
reg init;
always @(posedge clk) begin
    if (rst)
        init <= 1;
    else
        init <= 0;
end


endmodule

