/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* 8-Lane Dot Product Module                       */
/***************************************************/

module dot8 # (
    parameter IWIDTH = 8,
    parameter OWIDTH = 32
)(
    input clk,
    input rst,
    input signed [8*IWIDTH-1:0] vec0,
    input signed [8*IWIDTH-1:0] vec1,
    input ivalid,
    output signed [OWIDTH-1:0] result,
    output ovalid
);

/******* Your code starts here *******/
logic signed [IWIDTH-1:0] r_input_a [7:0];
logic signed [IWIDTH-1:0] r_input_b [7:0];
logic signed [2*IWIDTH-1:0] r_stage_1 [7:0];
logic signed [2*IWIDTH-1:0] r_stage_2 [3:0];
logic signed [OWIDTH-1:0] r_stage_3 [1:0];
logic signed [OWIDTH-1:0] r_out;
logic r_ovalid [4:0];
logic r_ivalid [4:0];

integer i; 

always_ff @ (posedge clk) begin
    if (rst) begin
        for (i = 0; i < IWIDTH; i = i + 1) begin
            r_input_a[i] <= 0;
            r_input_b[i] <= 0;
            r_stage_1[i] <= 0;
        end
        for (i=0; i < IWIDTH/2; i = i+1) begin
            r_stage_2[i] <= 0;
        end
        for (i=0; i < IWIDTH/4; i = i+1) begin
            r_stage_3[i] <= 0;
        end
        for (i = 0; i < 5; i = i+1) begin
            r_ivalid[i] <= 0;
        end
        r_out <= 0;
    end else begin
        // Propogate ivalid signal
        r_ivalid[0] <= ivalid;
        for (int i = 1; i < 5; i += 1) begin
            r_ivalid[i] <= r_ivalid[i-1];
        end
        
    // Stage 0: Register inputs
    r_input_a[0] <= vec0[0*IWIDTH +: IWIDTH];
    r_input_a[1] <= vec0[1*IWIDTH +: IWIDTH];
    r_input_a[2] <= vec0[2*IWIDTH +: IWIDTH];
    r_input_a[3] <= vec0[3*IWIDTH +: IWIDTH];
    r_input_a[4] <= vec0[4*IWIDTH +: IWIDTH];
    r_input_a[5] <= vec0[5*IWIDTH +: IWIDTH];
    r_input_a[6] <= vec0[6*IWIDTH +: IWIDTH];
    r_input_a[7] <= vec0[7*IWIDTH +: IWIDTH];

    r_input_b[0] <= vec1[0*IWIDTH +: IWIDTH];
    r_input_b[1] <= vec1[1*IWIDTH +: IWIDTH];
    r_input_b[2] <= vec1[2*IWIDTH +: IWIDTH];
    r_input_b[3] <= vec1[3*IWIDTH +: IWIDTH];
    r_input_b[4] <= vec1[4*IWIDTH +: IWIDTH];
    r_input_b[5] <= vec1[5*IWIDTH +: IWIDTH];
    r_input_b[6] <= vec1[6*IWIDTH +: IWIDTH];
    r_input_b[7] <= vec1[7*IWIDTH +: IWIDTH];
    
    // Stage 1: Multiplication
    for (i = 0; i < IWIDTH; i = i+ 1) begin
        r_stage_1[i] <= $signed(r_input_a[i]) * $signed(r_input_b[i]);
    end

    // Stage 2: Addition Layer 1
    r_stage_2[0] <= $signed(r_stage_1[0]) + $signed(r_stage_1[1]);
    r_stage_2[1] <= $signed(r_stage_1[2]) + $signed(r_stage_1[3]);
    r_stage_2[2] <= $signed(r_stage_1[4]) + $signed(r_stage_1[5]);
    r_stage_2[3] <= $signed(r_stage_1[6]) + $signed(r_stage_1[7]);
    
    // Stage 3: Addition Layer 2
    r_stage_3[0] <= $signed(r_stage_2[0]) + $signed(r_stage_2[1]);
    r_stage_3[1] <= $signed(r_stage_2[2]) + $signed(r_stage_2[3]);

    // Stage 4: Final Result
    r_out <= $signed(r_stage_3[0]) + $signed(r_stage_3[1]);

    end  
end    

assign result = r_out;
assign ovalid = r_ivalid[4];
/******* Your code ends here ********/

endmodule