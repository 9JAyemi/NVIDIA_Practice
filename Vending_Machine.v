/*
A  soda  vending  machine  that  can  deliver  three  kinds  of  soda, A, B and C.  
All the three soda  cost  the  same  amount -70  cents.  
The  vending  machine  has  four  coin  slots,  one each  for nickel (N = 5c), dime (I = 10c), quarter (Q = 25c) and dollar (D = 100c). 
Coins are inserted into the machine one at a time in any order. The machine should take coins until 70 cents or more has been  put  in.  
When  this  occurs,  the  machine  should  wait  for  the choice  of  the  soda A, B or C. 
After the choice is made, the machine is ready for vending.
The  machine  should  indicate  vending  by  turning  on  one  of  the lines A_O, B_O or C_O for  1 second.  
During  this  time  the  machine  cannot  accept  any  coins.  After  1  second,  the machine  is ready to accept coins again. 
The machine does not return any change. The machine should be a Finite  State  Machine  (FSM)  operating  with a  100 Hz clock.  
The machine  should  have  a  reset input  (R),  which  when  pressed  and  released  puts  the  machine in  READY  mode.  
Whenever  this happens,  the  machine  should  display  the  total  amount accumulated  since  last  reset. 
Also,  the internal amount accumulated is reset to zero cents.
*/
//RTL

module Vending_Machine(
    input clk,           // Clock signal
    input reset,         // Reset signal
    input [1:0] coin_in, // Coin input: 2'b00=5c, 2'b01=10c, 2'b10=25c, 2'b11 = 100c
    output reg dispense, // Dispense output signal
    output reg [6:0] Total_Amount // Total amount (7 bits, max value 127)
);

    // Parameters for coin values
    parameter COIN_5 = 5, COIN_10 = 10, COIN_25 = 25, COIN_100 = 100, ITEM_COST = 200;

    // Sequential logic to update the total amount
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Total_Amount <= 0;
            dispense <= 0;
        end else begin
            dispense <= 0;  // Reset dispense signal
            case (coin_in)
                2'b00: Total_Amount <= Total_Amount + COIN_5;
                2'b01: Total_Amount <= Total_Amount + COIN_10;
                2'b10: Total_Amount <= Total_Amount + COIN_25;
                2'b11: Total_Amount <= Total_Amount + COIN_100;
                default: Total_Amount <= Total_Amount;  // No change
            endcase

            // Check if enough money is inserted
            if (Total_Amount >= ITEM_COST) begin
                dispense <= 1;  // Dispense the item
                Total_Amount <= Total_Amount - ITEM_COST;  // Deduct cost
            end
        end
    end
endmodule