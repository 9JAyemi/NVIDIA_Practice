module wm_fsm (
    input clk,
    input rst,
    input start,
    input door_close,
    input filled,
    input detergent_added,
    
    input cycle_time_out,
    input drained,
    input spin_time_out,
    

    output door_lock,
    output fill_valve_on,
    output motor_on,
    output drain_valve_on,
    output water_wash,
    output soap_wash,
    output done
  //  output [3:0] curr_state
);

localparam CHECK_DOOR = 4'b0000;
localparam FILL_WATER = 4'b0001;
localparam ADD_DETERGENT = 4'b0010;
localparam CYCLE = 4'b0011;
localparam DRAIN_WATER = 4'b0100;
localparam SPIN = 4'b0101;

reg [3:0] state, nstate;

//Next State Combinational Logic
always @(*) begin
    nstate = state;
    case(state)
    CHECK_DOOR: begin
        if(start && door_close) begin
            nstate = FILL_WATER;
        end
    end
    FILL_WATER: begin
        if(filled) begin
        if(!soap_wash) begin
            nstate = ADD_DETERGENT;
        end
        else begin
            nstate = CYCLE;
        end
        end
    end
    ADD_DETERGENT: begin
        if(detergent_added) begin
            nstate = CYCLE;
        end
    end
    CYCLE: begin
        if(cycle_time_out) begin
            nstate = DRAIN_WATER;
        end
    end
    DRAIN_WATER: begin
        if(drained) begin
        if(!water_wash) begin
            nstate = FILL_WATER;
        end
        else begin
            nstate = SPIN;
        end
        end
    end
    SPIN: begin
        if(spin_time_out) begin
            nstate = CHECK_DOOR
        end
    end
    endcase
end

//Output Combinational Logic
always @(*) begin
    door_lock = 0;
    motor_on = 0;
    fill_valve_on = 0;
    drain_valve_on = 0;
    done = 0;
    soap_wash = 0;
     water_wash = 0;
    case(state)
        CHECK_DOOR: begin
            door_lock = 1;
        end
       FILL_WATER: begin
        if(filled) begin
            if(!soap_wash) begin
                    otor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 0;
					done = 0;
            end
            else begin
                motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 1;
					done = 0;
            end
        end 
        else begin
            motor_on = 0;
				fill_value_on = 1;
				drain_value_on = 0;
				door_lock = 1;
				done = 0;
        end
       end
       
        
    endcase
end
endmodule