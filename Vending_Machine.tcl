analyze -sv Vending_Machine.v

elaborate -top Vending_Machine

clock clk
reset reset


# check reset properties 
assert {reset |-> ##1 ((Total_Amount == 0) & (dispense == 0))}

# check total amount properties
assert {reset & coin_in == 2'b00 |-> ##1 (Total_Amount == 5)}
assert {reset & coin_in == 2'b01 |-> ##1 Total_Amount == 10}
assert {reset & coin_in == 2'b10 |-> ##1 Total_Amount == 25}
assert {reset & coin_in == 2'b11 |-> ##1 Total_Amount == 100}

assume {$past(coin_in) == 2'b10}
assert {coin_in == 2'b11 |-> ##1 Total_Amount == 125}

# dispense properties and subtraction
assert {(Total_Amount == ITEM_COST) || (Total_Amount > ITEM_COST)  |-> dispense == 1 }
assert {!reset && (Total_Amount < ITEM_COST) |-> (dispense == 0)}
assume {$past(dispense) == 1}
assert {$rose(clk) |-> dispense != 1}

# Set the time limit to 1 hour (3600 seconds)
set_prove_time_limit 3600
set_engine_mode Tri
prove -all