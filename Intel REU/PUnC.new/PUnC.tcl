analyze -sv PUnC.v

elaborate -top PUnC


clock clk
reset rst

assert {rst |-> ##2 pc_debug_data == 0}

assert {(!rst) && ir_output[15:12] == 4'b0001 && bit_5 == 0 |-> ##1 pc_debug_data == $past(pc_debug_data)}

prove -all