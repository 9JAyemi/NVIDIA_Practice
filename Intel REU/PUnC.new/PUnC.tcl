analyze -sv PUnC.v

elaborate -top PUnC


clock clk
reset rst

assert {rst |-> ##2 pc_ld == 0}
assert {ir_output[15:12] == 4'b0001 && ir_output[5] == 0 |-> ##1 reg_w_en_sig && pc_ld && alu_sig == 2'b00 }

prove -all