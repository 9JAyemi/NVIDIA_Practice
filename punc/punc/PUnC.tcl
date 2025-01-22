analyze -sv PUnC1.v
elaborate -top PUnC1

clock clk
reset rst

assert {rst |-> pc_clr}

prove -all