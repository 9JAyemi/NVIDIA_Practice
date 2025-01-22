analyze -sv PUnC.v
elaborate -top PUnC

clock clk
reset rst

assert {rst |-> pc_clr}