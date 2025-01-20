analyze -sv Simon.v

elaborate -top Simon

clock pclk
reset rst

#If level is 1 then pattern may contain up to 4 bits
assert {mode_leds == 3'b001 && pclk && level == 0 -> (pattern == 1 || pattern == 2 || pattern == 4 || pattern == 8 || pattern == 0)}

#If in INPUT stage a legal pattern must be made in order to transition to PLAYBACK stage
assert {level == 0 && mode_leds == 3'b001 && (pattern == 1 || pattern == 2 || pattern == 4 || pattern == 8 || pattern == 0) && pclk -> mode_leds == 3'b010}
assert {level == 1 && mode_leds == 3'b001 && pclk -> mode_leds == 3'b010}
assert {level == 0 && mode_leds == 3'b001 && (pattern != 1 || pattern != 2 || pattern != 4 || pattern != 8 || pattern != 0) && pclk -> mode_leds == 3'b001}

#Upon switch in pattern, pattern_leds should change instantaneously
assert {pclk |-> pattern_leds == pattern }

#In PLAYBACK stage, every press of pclk should have the pattern_leds playback the patterns one at 
#a time until there is no patterns left (I dont know how to test for multiple sets i.e when I need to set pattern twice in order to make sure pattern_leds plays back correctly)
#assert {mode_leds == 3'b010 && pclk }

# upon rest, the mode should be set to input
assert { rst -> mode_leds == 3'b001}

prove -all