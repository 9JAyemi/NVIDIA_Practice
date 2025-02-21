analyze -sv Simon.v

elaborate -top Simon

clock uclk
reset rst

#If level is 0 then pattern may contain up to 1 bit
# assert {level == 0 -> (pattern[0] == 1 ^ pattern[1] == 1 ^ pattern[2] == 1 ^ pattern[3] == 1) ^ pattern == 0 }
assert {level == 0 && reset && legal |-> ((pattern == 4'b0001) ^ (pattern == 4'b0010) ^ (pattern == 4'b0100) ^ (pattern == 4'b1000)) }

#If in INPUT stage a legal pattern must be made in order to transition to PLAYBACK stage
assert {level == 0 && mode_leds == 3'b001 && pattern == 3'b0001 |-> ##1 mode_leds == 3'b010}
assert {reset && level == 1 && mode_leds == 3'b001 && pattern == 3'b0101 |-> ##1 mode_leds == 3'b010}

assert {reset && level == 0 && mode_leds == 3'b001 && pattern == 3'b0101 |-> ##1 mode_leds == 3'b001}

#Upon switch in pattern, pattern_leds should change instantaneously
assert {pclk |=> pattern_leds == pattern }

# assume {$rose(pclk) && $fell(pclk) |-> ##9 mode_leds == 3'b010}
# assert {$rose(pclk) && $fell(pclk) |-> ##10 rst_i != 1 }

assert {(mode_leds == 3'b010) && (!i_eq_ns) |-> ##1 mode_leds == $past(mode_leds)}

# assume {!rst}
assert {(mode_leds == 3'b100) && (!right_guess) && rst |-> ##1 (mode_leds == 3'b111)}

#In PLAYBACK stage, every press of pclk should have the pattern_leds playback the patterns one at 
#a time until there is no patterns left (I dont know how to test for multiple sets i.e when I need to set pattern twice in order to make sure pattern_leds plays back correctly)
#assert {mode_leds == 3'b010 && pclk } i do now!


prove -all