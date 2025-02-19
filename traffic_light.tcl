analyze -sv traffic_light.v
elaborate -top traffic_control

clock clk
reset rst_a

#reset condtion
assert {(rst_a) |-> ##1 (state == 0) && (count == 0)}

#ensure that state is still in north when count is not at 7
assert {(state == north) && (count != 3'b111) |-> ##1 (state == $past(state)) }

#ensure state transition
assert {(state == north) && (count == 3'b111) |-> ##1 (state == north)}

set_prove_time_limit 3600
set_engine_mode Tri
prove -all