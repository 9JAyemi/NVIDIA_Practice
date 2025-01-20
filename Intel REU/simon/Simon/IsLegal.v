//==============================================================================
// Checks if 4-bit pattern is legal on easy mode
//==============================================================================

module IsLegal
(
    // Inputs
    input level,
    input [3:0] pattern,

    // Output
    output reg legal
);

always @( * ) begin
    legal = 0;

    if (level) begin
        legal = 1;
    end

    else begin
        if (pattern == 4'b0001 | pattern == 4'b0010 | pattern == 4'b0100 | pattern == 4'b1000) begin
            legal = 1;
        end
    end 
end

endmodule