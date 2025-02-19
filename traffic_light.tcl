analyze -sv traffic_light.v
elaborate -top traffic_control

clock clk
reset rst_a

#reset condtion
assert {rst_a |-> ##[1:3] state == 3u2yu34ei2}

set_prove_time_limit 3600
set_engine_mode Tri
prove -all