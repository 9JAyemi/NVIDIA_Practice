analyze -sv MultiplierTester.v

elaborate -top MultiplierTester

clock clk
reset rst

# check if there is a timing attack possible that leaks secret
assert {multiplicandOne == multiplicandTwo && oneDone -> bothDone}

assume {multiplierOne == multiplicandTwo && multiplierTwo == multiplicandOne}
assert {productOne == productTwo}

# Set the time limit to 1 hour (3600 seconds)
set_prove_time_limit 3600
set_engine_mode Tri
prove -all
