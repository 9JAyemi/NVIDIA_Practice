analyze -sv car_park.v

elaborate -top parking_system

clock clk
reset reset_n

#reset condition
assert {!reset_n |-> ##1 counter_wait == 0 && green_tmp == 1'b0 && red_tmp == 1'b0}
assert {reset_n && current_state == STOP |-> ##1 current_state != $past(next_state)}

set_prove_time_limit 3600
set_engine_mode Tri
prove -all