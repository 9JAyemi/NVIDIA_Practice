analyze -sva selfcomp_buggy_cache.v

elaborate -top BuggyCacheTester -bbox_mul 256

#specify clock and reset
clock clock
reset reset -non_resettable_regs 0

stopat se1.aes_invcipher.io_output_op1_*
stopat se1.aes_invcipher.io_output_op2_*
stopat se2.aes_invcipher.io_output_op1_*
stopat se2.aes_invcipher.io_output_op2_*

stopat se1._output_buffer_T
stopat se2._output_buffer_T

assume {se1._output_buffer_T == se2._output_buffer_T}
assume {init -> (se1.cache_valid_neg_0 == se2.cache_valid_neg_0 && se1.cache_valid_neg_1 == se2.cache_valid_neg_1 && se1.cache_valid_neg_2 == se2.cache_valid_neg_2 && se1.cache_valid_neg_3 == se2.cache_valid_neg_3 && se1.cache_valid_neg_4 == se2.cache_valid_neg_4 && se1.cache_valid_neg_5 == se2.cache_valid_neg_5 && se1.cache_valid_neg_6 == se2.cache_valid_neg_6 && se1.cache_valid_neg_7 == se2.cache_valid_neg_7 && se1.cache_valid_neg_8 == se2.cache_valid_neg_8 && se1.cache_valid_neg_9 == se2.cache_valid_neg_9 && se1.cache_valid_neg_10 == se2.cache_valid_neg_10 && se1.cache_valid_neg_11 == se2.cache_valid_neg_11 && se1.cache_valid_neg_12 == se2.cache_valid_neg_12 && se1.cache_valid_neg_13 == se2.cache_valid_neg_13 && se1.cache_valid_neg_14 == se2.cache_valid_neg_14 && se1.cache_valid_neg_15 == se2.cache_valid_neg_15)}
assume {init -> (se1.cache_valid_pos_0 == se2.cache_valid_pos_0 && se1.cache_valid_pos_1 == se2.cache_valid_pos_1 && se1.cache_valid_pos_2 == se2.cache_valid_pos_2 && se1.cache_valid_pos_3 == se2.cache_valid_pos_3 && se1.cache_valid_pos_4 == se2.cache_valid_pos_4 && se1.cache_valid_pos_5 == se2.cache_valid_pos_5 && se1.cache_valid_pos_6 == se2.cache_valid_pos_6 && se1.cache_valid_pos_7 == se2.cache_valid_pos_7 && se1.cache_valid_pos_8 == se2.cache_valid_pos_8 && se1.cache_valid_pos_9 == se2.cache_valid_pos_9 && se1.cache_valid_pos_10 == se2.cache_valid_pos_10 && se1.cache_valid_pos_11 == se2.cache_valid_pos_11 && se1.cache_valid_pos_12 == se2.cache_valid_pos_12 && se1.cache_valid_pos_13 == se2.cache_valid_pos_13 && se1.cache_valid_pos_14 == se2.cache_valid_pos_14 && se1.cache_valid_pos_15 == se2.cache_valid_pos_15)}
#assume {reset -> (se1.cache_valid_neg_0 == se2.cache_valid_neg_0 && se1.cache_valid_neg_1 == se2.cache_valid_neg_1 && se1.cache_valid_neg_2 == se2.cache_valid_neg_2 && se1.cache_valid_neg_3 == se2.cache_valid_neg_3 && se1.cache_valid_neg_4 == se2.cache_valid_neg_4 && se1.cache_valid_neg_5 == se2.cache_valid_neg_5 && se1.cache_valid_neg_6 == se2.cache_valid_neg_6 && se1.cache_valid_neg_7 == se2.cache_valid_neg_7 && se1.cache_valid_neg_8 == se2.cache_valid_neg_8 && se1.cache_valid_neg_9 == se2.cache_valid_neg_9 && se1.cache_valid_neg_10 == se2.cache_valid_neg_10 && se1.cache_valid_neg_11 == se2.cache_valid_neg_11 && se1.cache_valid_neg_12 == se2.cache_valid_neg_12 && se1.cache_valid_neg_13 == se2.cache_valid_neg_13 && se1.cache_valid_neg_14 == se2.cache_valid_neg_14 && se1.cache_valid_neg_15 == se2.cache_valid_neg_15)}
#assume {reset -> (se1.cache_valid_pos_0 == se2.cache_valid_pos_0 && se1.cache_valid_pos_1 == se2.cache_valid_pos_1 && se1.cache_valid_pos_2 == se2.cache_valid_pos_2 && se1.cache_valid_pos_3 == se2.cache_valid_pos_3 && se1.cache_valid_pos_4 == se2.cache_valid_pos_4 && se1.cache_valid_pos_5 == se2.cache_valid_pos_5 && se1.cache_valid_pos_6 == se2.cache_valid_pos_6 && se1.cache_valid_pos_7 == se2.cache_valid_pos_7 && se1.cache_valid_pos_8 == se2.cache_valid_pos_8 && se1.cache_valid_pos_9 == se2.cache_valid_pos_9 && se1.cache_valid_pos_10 == se2.cache_valid_pos_10 && se1.cache_valid_pos_11 == se2.cache_valid_pos_11 && se1.cache_valid_pos_12 == se2.cache_valid_pos_12 && se1.cache_valid_pos_13 == se2.cache_valid_pos_13 && se1.cache_valid_pos_14 == se2.cache_valid_pos_14 && se1.cache_valid_pos_15 == se2.cache_valid_pos_15)}
#assume {reset -> (se1.cache_valid_pos_0 == 0 && se1.cache_valid_pos_1 == 0 && se1.cache_valid_pos_2 == 0 && se1.cache_valid_pos_3 == 0 && se1.cache_valid_pos_4 == 0 && se1.cache_valid_pos_5 == 0 && se1.cache_valid_pos_6 == 0 && se1.cache_valid_pos_7 == 0 && se1.cache_valid_pos_8 == 0 && se1.cache_valid_pos_9 == 0 && se1.cache_valid_pos_10 == 0 && se1.cache_valid_pos_11 == 0 && se1.cache_valid_pos_12 == 0 && se1.cache_valid_pos_13 == 0 && se1.cache_valid_pos_14 == 0 && se1.cache_valid_pos_15 == 0)}
#assume {reset -> (se1.cache_valid_neg_0 == 0 && se1.cache_valid_neg_1 == 0 && se1.cache_valid_neg_2 == 0 && se1.cache_valid_neg_3 == 0 && se1.cache_valid_neg_4 == 0 && se1.cache_valid_neg_5 == 0 && se1.cache_valid_neg_6 == 0 && se1.cache_valid_neg_7 == 0 && se1.cache_valid_neg_8 == 0 && se1.cache_valid_neg_9 == 0 && se1.cache_valid_neg_10 == 0 && se1.cache_valid_neg_11 == 0 && se1.cache_valid_neg_12 == 0 && se1.cache_valid_neg_13 == 0 && se1.cache_valid_neg_14 == 0 && se1.cache_valid_neg_15 == 0)}
#assume {reset -> (se2.cache_valid_pos_0 == 0 && se2.cache_valid_pos_1 == 0 && se2.cache_valid_pos_2 == 0 && se2.cache_valid_pos_3 == 0 && se2.cache_valid_pos_4 == 0 && se2.cache_valid_pos_5 == 0 && se2.cache_valid_pos_6 == 0 && se2.cache_valid_pos_7 == 0 && se2.cache_valid_pos_8 == 0 && se2.cache_valid_pos_9 == 0 && se2.cache_valid_pos_10 == 0 && se2.cache_valid_pos_11 == 0 && se2.cache_valid_pos_12 == 0 && se2.cache_valid_pos_13 == 0 && se2.cache_valid_pos_14 == 0 && se2.cache_valid_pos_15 == 0)}
#assume {reset -> (se2.cache_valid_neg_0 == 0 && se2.cache_valid_neg_1 == 0 && se2.cache_valid_neg_2 == 0 && se2.cache_valid_neg_3 == 0 && se2.cache_valid_neg_4 == 0 && se2.cache_valid_neg_5 == 0 && se2.cache_valid_neg_6 == 0 && se2.cache_valid_neg_7 == 0 && se2.cache_valid_neg_8 == 0 && se2.cache_valid_neg_9 == 0 && se2.cache_valid_neg_10 == 0 && se2.cache_valid_neg_11 == 0 && se2.cache_valid_neg_12 == 0 && se2.cache_valid_neg_13 == 0 && se2.cache_valid_neg_14 == 0 && se2.cache_valid_neg_15 == 0)}

assert {oneValid -> bothValid}
assert {io_out_resultOne == io_out_resultTwo}

#se1
abstract -init_value {se1.cache_valid_neg_0 se1.cache_valid_neg_1 se1.cache_valid_neg_2 se1.cache_valid_neg_3 se1.cache_valid_neg_4 se1.cache_valid_neg_5 se1.cache_valid_neg_6 se1.cache_valid_neg_7 se1.cache_valid_neg_8 se1.cache_valid_neg_9 se1.cache_valid_neg_10 se1.cache_valid_neg_11 se1.cache_valid_neg_12 se1.cache_valid_neg_13 se1.cache_valid_neg_14 se1.cache_valid_neg_15}
abstract -init_value {se1.cache_valid_pos_0 se1.cache_valid_pos_1 se1.cache_valid_pos_2 se1.cache_valid_pos_3 se1.cache_valid_pos_4 se1.cache_valid_pos_5 se1.cache_valid_pos_6 se1.cache_valid_pos_7 se1.cache_valid_pos_8 se1.cache_valid_pos_9 se1.cache_valid_pos_10 se1.cache_valid_pos_11 se1.cache_valid_pos_12 se1.cache_valid_pos_13 se1.cache_valid_pos_14 se1.cache_valid_pos_15}

#se2
abstract -init_value {se2.cache_valid_neg_0 se2.cache_valid_neg_1 se2.cache_valid_neg_2 se2.cache_valid_neg_3 se2.cache_valid_neg_4 se2.cache_valid_neg_5 se2.cache_valid_neg_6 se2.cache_valid_neg_7 se2.cache_valid_neg_8 se2.cache_valid_neg_9 se2.cache_valid_neg_10 se2.cache_valid_neg_11 se2.cache_valid_neg_12 se2.cache_valid_neg_13 se2.cache_valid_neg_14 se2.cache_valid_neg_15}
abstract -init_value {se2.cache_valid_pos_0 se2.cache_valid_pos_1 se2.cache_valid_pos_2 se2.cache_valid_pos_3 se2.cache_valid_pos_4 se2.cache_valid_pos_5 se2.cache_valid_pos_6 se2.cache_valid_pos_7 se2.cache_valid_pos_8 se2.cache_valid_pos_9 se2.cache_valid_pos_10 se2.cache_valid_pos_11 se2.cache_valid_pos_12 se2.cache_valid_pos_13 se2.cache_valid_pos_14 se2.cache_valid_pos_15}

prove -bg -all

set_engine_mode auto