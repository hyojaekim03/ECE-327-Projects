/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 2 - Part 2                                  */
/* Traffic Light Controller Testbench              */
/***************************************************/

`timescale 1ns/1ps

// Define the name of this testbench module. Since testbenches typically generate inputs and
// monitor outputs of the circuit being tested, they usually do not have any input/output ports.
module traffic_tb ();

// Assumed no. of clock cycles per second to be passed to the traffic light controller module.
// It is set to 16 instead of 125000000 in the testbench to run shorted simulation. Refer to
// the Lab 2 handout for a more detailed explanation
localparam CYCLES_PER_SEC = 16; 
localparam CLK_PERIOD = 2; // Clock period in nanoseconds

// Design specific parameters that could help you when writing the testbench. A traffic cycle
// is 10 seconds and a pedestrian crossing slot is 4 seconds. You can choose not to use these
// parameters if you want, but they should make your testbench cleaner.
localparam bit [63:0] CYCLES_PER_TRAFFIC_CYCLE = 10 * CYCLES_PER_SEC;
localparam bit [63:0] CYCLES_PER_PEDESTRIAN_CROSSING = 4 * CYCLES_PER_SEC;

// Declare logic signals for the circuit's inputs/outputs
logic clk;
logic i_maintenance;
logic [3:0] i_ped_buttons;
logic [2:0] o_light_ns;
logic [2:0] o_light_ew;
logic o_light_ped;

// Signal to identify if simulation passed (1'b0) or failed (1'b1). Your testbench should test
// the design and set this signal accordingly.
logic sim_failed;

// Instantiate the design under test (dut), set the desired values of its parameters, and connect 
// its input/output ports to the declared signals.
traffic # (
    .CYCLES_PER_SEC(CYCLES_PER_SEC)
) dut (
    .clk(clk),
    .i_maintenance(i_maintenance),
    .i_ped_buttons(i_ped_buttons),
    .o_light_ns(o_light_ns),
    .o_light_ew(o_light_ew),
    .o_light_ped(o_light_ped)
);

// This initial block generates a clock signal
initial begin
    clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

/******* Your code starts here *******/
localparam GREEN_LIGHT  = 3'b010,
           YELLOW_LIGHT = 3'b110,
           RED_LIGHT    = 3'b100;
           
logic t1;
logic t2;
logic t3;
logic t4;
logic t5;

/******* Your code ends here ********/

initial begin
    // Reset all testbench signals
    sim_failed = 1'b0;
    i_maintenance = 1'b1;
    i_ped_buttons = 4'b0000;
    #(5*CLK_PERIOD);
    
    /******* Your code starts here *******/
    //$monitor($time, "i_maintainance: i_maintenance=%d, i_ped_btns: i_ped_buttons=%d, o_light_ns: o_light_ns=%d, o_light_ew: o_light_ew=%d, o_light_ped: o_light_ped=%d", i_maintenance, i_ped_buttons, o_light_ns, o_light_ew, o_light_ped);

    // **** TEST 1 ****

    // Ensure everything remains in initial state for 1 whole traffic cycle when i_maintenance is on
    t1 = 1;
    for (int i = 0; i < CYCLES_PER_SEC*10; i = i + 1) begin
        @(posedge clk);
        if (o_light_ns != GREEN_LIGHT || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    t1 = 0;
    
    // **** TEST 2 ****
    t2 = 1;
    // Set maintenance = 0, and observe complete traffic flow with NO pedestrian crossing requests;
    i_maintenance = 1'b0; i_ped_buttons = 4'b0000;

    // ns_green
    for (int i = 0; i < CYCLES_PER_SEC*3; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != GREEN_LIGHT || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ns_yellow
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != YELLOW_LIGHT  || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ew_green
    for (int i = 0; i < CYCLES_PER_SEC*3; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != RED_LIGHT || o_light_ew != GREEN_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ew yellow
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
        if (o_light_ns != RED_LIGHT || o_light_ew != YELLOW_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    t2 = 0;
    
    // **** TEST 3 ****
    t3 = 1;
     // Set maintenance = 0, and observe complete traffic flow WITH pedestrian crossing requested
     // This also tests if the FSM ignores additional btn presses before or during the pedestrian crossing stages
    
     // ns_green
    for (int i = 0; i < CYCLES_PER_SEC*3; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != GREEN_LIGHT || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ns_yellow
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
        if(i == 3) begin // Request pedestrian crossing
           i_ped_buttons = 0100;
        end
        if(i == 5) begin // De-assert request pedestrian crossing
           i_ped_buttons = 0000;
        end
         if (o_light_ns != YELLOW_LIGHT  || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ew_green
    for (int i = 0; i < CYCLES_PER_SEC*3; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != RED_LIGHT || o_light_ew != GREEN_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ew yellow
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
        if (i % (CYCLES_PER_SEC/2) == 0) begin // Continiously toggle pedestrian crossing requests
            i_ped_buttons = 0010;
        end else begin
            i_ped_buttons = 0000;
        end
        if (o_light_ns != RED_LIGHT || o_light_ew != YELLOW_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // pd_on
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
        if (i % (CYCLES_PER_SEC/2) == 0) begin // Continiously toggle pedestrian crossing requests
            i_ped_buttons = 0001;
        end else begin
            i_ped_buttons = 0000;
        end
         if (o_light_ns != RED_LIGHT|| o_light_ew != RED_LIGHT || o_light_ped != 1) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // pd_flash
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
        if (i % CYCLES_PER_SEC == 0) begin // Continiously toggle pedestrian crossing requests
            i_ped_buttons = 1000;
        end else begin
            i_ped_buttons = 0000;
        end
        if ((i / (CYCLES_PER_SEC / 4)) % 2 == 0) begin
            if(o_light_ped != 0 || o_light_ns != RED_LIGHT || o_light_ew != RED_LIGHT) begin 
                sim_failed = 1;
            end
        end else begin
            if(o_light_ped != 1 || o_light_ns != RED_LIGHT || o_light_ew != RED_LIGHT) begin
                sim_failed = 1;
            end
        end
    end
    
    // Ensure it begins new traffic cycle 
    
    // ns_green
    for (int i = 0; i < CYCLES_PER_SEC*3; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != GREEN_LIGHT || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ns_yellow
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
        if (o_light_ns != YELLOW_LIGHT  || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    t3 = 0;
    
    // **** TEST 4 ****
    // Ensure that i_maintenance signal directly transitions to reset state
    t4 = 1;
    i_maintenance = 1'b1;
    
    for (int i = 0; i < CYCLES_PER_SEC*10; i = i + 1) begin
        @(posedge clk);
        if (o_light_ns != GREEN_LIGHT || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    t4 = 0;
    
    // **** TEST 5 ****
    // Ensure it transitions to maintenance state during pedestrian crossing directly as well
    i_maintenance = 1'b0;
    t5 = 1;
    
    // ns_green
    for (int i = 0; i < CYCLES_PER_SEC*3; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != GREEN_LIGHT || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ns_yellow
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != YELLOW_LIGHT  || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ew_green
    for (int i = 0; i < CYCLES_PER_SEC*3; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != RED_LIGHT || o_light_ew != GREEN_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ew yellow
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
        if (i == 26) begin // Request pedestrian crossing
            i_ped_buttons = 0001;
        end 
        if (o_light_ns != RED_LIGHT || o_light_ew != YELLOW_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    i_ped_buttons = 0000; // De-assert pedestrian crossing
    
    // pd_on
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
        if (i == (CYCLES_PER_SEC / 4)) begin // Trigger i_maintenance
            i_maintenance = 1'b1;
            break;
        end
         if (o_light_ns != RED_LIGHT|| o_light_ew != RED_LIGHT || o_light_ped != 1) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // Verify it stays in maintenance until signal deasserted
    for (int i = 0; i < CYCLES_PER_SEC*7; i = i + 1) begin
        @(posedge clk);
        if (o_light_ns != GREEN_LIGHT || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    i_maintenance = 1'b0;
    
    // ns_green
    for (int i = 0; i < CYCLES_PER_SEC*3; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != GREEN_LIGHT || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ns_yellow
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != YELLOW_LIGHT  || o_light_ew != RED_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ew_green
    for (int i = 0; i < CYCLES_PER_SEC*3; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != RED_LIGHT || o_light_ew != GREEN_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // ew yellow
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
        if (i == (CYCLES_PER_SEC / 4)) begin // Assert pedestrian crossing request
            i_ped_buttons = 0010;
        end
        if (i == (CYCLES_PER_SEC / 2)) begin // De-assert pedestrian crossing request
            i_ped_buttons = 0000;
        end
        if (o_light_ns != RED_LIGHT || o_light_ew != YELLOW_LIGHT || o_light_ped != 0) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // pd_on
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
         if (o_light_ns != RED_LIGHT|| o_light_ew != RED_LIGHT || o_light_ped != 1) begin
            sim_failed = 1; 
            $error("Simulation failed");
        end
    end
    
    // pd_flash
    for (int i = 0; i < CYCLES_PER_SEC*2; i = i + 1) begin
        @(posedge clk);
        if ((i / (CYCLES_PER_SEC / 4)) % 2 == 0) begin
            if(o_light_ped != 0 || o_light_ns != RED_LIGHT || o_light_ew != RED_LIGHT) begin 
                sim_failed = 1;
            end
        end else begin
            if(o_light_ped != 1 || o_light_ns != RED_LIGHT || o_light_ew != RED_LIGHT) begin
                sim_failed = 1;
            end
        end
    end
    
    t5 = 0;
    
    /******* Your code ends here ********/
    
    if (sim_failed) begin
        $display("TEST FAILED!");
    end else begin
        $display("TEST PASSED!");
    end 
    $stop;
end


endmodule