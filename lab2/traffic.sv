/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 2 - Part 1                                  */
/* Traffic Light Controller Module                 */
/***************************************************/

module traffic # (
    parameter CYCLES_PER_SEC = 125000000 // No. of clock cycles per 1 second of wall clock time
)(
    input  clk,                 // Input clock signal
    input  i_maintenance,       // Maintenance signal
    input  [3:0] i_ped_buttons, // Four input pedestrian crossing push buttons
    output [2:0] o_light_ns,    // Traffic light of North-South street {red, green, blue}
    output [2:0] o_light_ew,    // Traffic light of East-West street {red, green, blue}
    output o_light_ped          // Pedestrian all-way crossing light
);

// Define local parameters for the RGB outputs corresponding to red, yellow, and green lights
// This allows you to cleanely set traffic light outputs (e.g., r_light_ns <= GREEN_LIGHT)
localparam GREEN_LIGHT  = 3'b010,
           YELLOW_LIGHT = 3'b110,
           RED_LIGHT    = 3'b100;

// Output registers assigned to the output ports of the module. Your FSM logic will set the
// values of these registers.           
logic [2:0] r_light_ns, r_light_ew;
logic r_light_ped;

/******* Your code starts here *******/
enum {R, NS_G, NS_Y, EW_G, EW_Y, P_ON, P_F} state, next_state;
logic [32:0] t_cycles;
logic [3:0] t_sec; 
logic [1:0] ped_req;
logic [1:0] f_on; 
logic [32:0] ped_timer;

logic [2:0] ns_out;
logic [2:0] ew_out;
logic ped_out;

always_ff @ (posedge clk) begin 
    if (i_maintenance) begin
        state <= NS_G;
        t_cycles <= 0;
        t_sec <= 0;
        ped_req <= 0;
        ped_timer <= 0;
        f_on <= 0;
    end else begin 
        t_cycles <= t_cycles + 1;
        if (t_cycles == CYCLES_PER_SEC-1) begin
            t_cycles <= 0;
            t_sec <= t_sec + 1;
        end
        
        // End of traffic cycle (restart or allow pedestrian crossing if requested)
        if (t_sec == 10 || (t_sec == 4  && state == P_F)) begin
            t_sec <= 0;
            ped_req <= 0;
        end
        
        // Check if pedestrian corssing requested & hold its value till end of traffic cycle
        ped_req <= (i_ped_buttons != 0 || ped_req == 1) ? 1 : 0;
        
        state <= next_state;

    end       
end

always_comb begin: state_decoder
    // Determine FSM state
    case (state)
        NS_G : next_state = (t_sec == 3) ? NS_Y : NS_G;
        NS_Y : next_state = (t_sec == 5) ? EW_G : NS_Y;
        EW_G : next_state = (t_sec == 8) ? EW_Y : EW_G;
        EW_Y : next_state = (t_sec == 10) ? ((ped_req) ? P_ON : NS_G) : EW_Y;
        P_ON : next_state = (t_sec == 2) ? P_F : P_ON; 
        P_F : next_state = (t_sec == 4) ? NS_G : P_F;
        default: next_state = NS_G;
    endcase
end
         
always_comb begin: out_decoder
    case (state)
        
        NS_G: begin
            r_light_ns = GREEN_LIGHT; r_light_ew = RED_LIGHT; r_light_ped = 0;
        end      
      
        NS_Y: begin
           r_light_ns = YELLOW_LIGHT; r_light_ew = RED_LIGHT; r_light_ped = 0;
        end    
           
        EW_G: begin
            r_light_ew = GREEN_LIGHT; r_light_ns = RED_LIGHT; r_light_ped = 0;
        end    
            
        EW_Y: begin
            r_light_ew = YELLOW_LIGHT; r_light_ns = RED_LIGHT; r_light_ped = 0; 
        end    
            
        P_ON: begin
            r_light_ew = RED_LIGHT; r_light_ns = RED_LIGHT;  r_light_ped = 1;
        end    
            
        P_F: begin
            r_light_ew = RED_LIGHT; r_light_ns = RED_LIGHT;
            
            if (((t_cycles - 1) / (CYCLES_PER_SEC / 4)) % 2 == 0) begin
                r_light_ped = 0;
            end else begin
               r_light_ped = 1;
            end
        end
        
        default begin
            r_light_ns = GREEN_LIGHT; r_light_ew = RED_LIGHT; r_light_ped = 0;
        end    
     endcase
end


/******* Your code ends here ********/

// Assignt the output registers set by your FSM logic to the input/output ports of the module.
assign o_light_ns = r_light_ns;
assign o_light_ew = r_light_ew;
assign o_light_ped = r_light_ped;

endmodule