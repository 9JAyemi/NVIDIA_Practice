analyze -sv traffic_light.v
elaborate -top traffic_control

clock clk
reset rst_a

#reset condtion
assert {rst_a |-> ##[1:3] state == north}