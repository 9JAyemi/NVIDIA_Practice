analyze -sv PUnC.v

elaborate -top PUnC


clock clk
reset rst

assert {rst |-> ##1 pc_ld == 0}
assert {ir[15:12] == 0 && ir[5] == 0 |-> ##1 w_data_mem_sig && pc_ld && alu_sig == 2'b00 }

prove -all