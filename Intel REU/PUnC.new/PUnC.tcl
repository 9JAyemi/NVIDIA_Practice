analyze -sv PUnC.v

elaborate -top PUnC


clock clk
reset rst

assert {rst |-> ##1 pc_debug_data == 0}


assert {(!rst) && opcode == 4'b0001 && bitfive== 0 |-> ##1 pc_debug_data == $past(pc_debug_data) + 1}

assert {(!rst) && state == 2'b01 |-> ##1 }

prove -all