/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 3                                           */
/* Hyperbolic Tangent (Tanh) circuit               */
/***************************************************/

module tanh (
    input  clk,         // Input clock signal
    input  rst,         // Active-high reset signal
    // Input interface
    input  [13:0] i_x,  // Input value x
    input  i_valid,     // Input value x is valid
    output o_ready,     // Circuit is ready to accept an input
    // Output interface 
    output [13:0] o_fx, // Output result f(x)
    output o_valid,     // Output result f(x) is valid
    input  i_ready      // Downstream circuit is ready to accept an input
);

// Local parameters to define the Taylor coefficients
localparam signed [13:0] A0 = 14'b11101010101011; // a0 = -0.33349609375
localparam signed [13:0] A1 = 14'b00001000100010; // a1 =  0.13330078125
localparam signed [13:0] A2 = 14'b11111100100011; // a2 = -0.05419921875
localparam signed [13:0] A3 = 14'b00000001011001; // a3 =  0.021484375
localparam signed [13:0] A4 = 14'b11111111011100; // a4 = -0.0087890625

// Registers
logic signed [13:0] x_pipeline [0:19]; // Stores original i_x val
logic signed [13:0] x2_pipeline[0:14]; // Stores the i_x squared val
logic signed [13:0] result_pipeline[0:12]; // Stores result from each pipeline stage
logic               valid_pipeline[0:19]; // Stores i_valid bit across pipeline
logic signed [27:0] mul_stage[0:6]; // Store intermediate value after multiplying

integer i;

always_ff @(posedge clk) begin
    if (rst) begin // Reset all resgister values
        for (i = 0; i <= 19; i++) begin
            x_pipeline[i]      <= 0;
            x2_pipeline[i]     <= 0;
            valid_pipeline[i]  <= 0;
        end
        for (i = 0; i <= 12; i++) begin
            result_pipeline[i] <= 0;
        end
        for (i = 0; i <= 6; i++) begin
            mul_stage[i] <= 0;
        end
    end else if (i_ready) begin
        // Stage 0 - Capture inputs
        x_pipeline[0]      <= i_x;
        valid_pipeline[0]  <= i_valid;

        // Stage 1
        mul_stage[0]       <= $signed(x_pipeline[0]) * $signed(x_pipeline[0]);
        x_pipeline[1]      <= x_pipeline[0];
        valid_pipeline[1]  <= valid_pipeline[0];

        result_pipeline[1] <= mul_stage[0] >>> 12;
        x2_pipeline[2]     <= mul_stage[0] >>> 12;
        x_pipeline[2]      <= x_pipeline[1];
        valid_pipeline[2]  <= valid_pipeline[1];

        // Stage 2
        mul_stage[1]       <= $signed(result_pipeline[1]) * A4;
        x_pipeline[3]      <= x_pipeline[2];
        x2_pipeline[3]     <= x2_pipeline[2];
        valid_pipeline[3]  <= valid_pipeline[2];

        result_pipeline[2] <= mul_stage[1] >>> 12;
        x_pipeline[4]      <= x_pipeline[3];
        x2_pipeline[4]     <= x2_pipeline[3];
        valid_pipeline[4]  <= valid_pipeline[3];

        // Stage 3
        result_pipeline[3] <= result_pipeline[2] + A3;
        x_pipeline[5]      <= x_pipeline[4];
        x2_pipeline[5]     <= x2_pipeline[4];
        valid_pipeline[5]  <= valid_pipeline[4];

        // Stage 4
        mul_stage[2]       <= $signed(result_pipeline[3]) * $signed(x2_pipeline[5]);
        x_pipeline[6]      <= x_pipeline[5];
        x2_pipeline[6]     <= x2_pipeline[5];
        valid_pipeline[6]  <= valid_pipeline[5];

        result_pipeline[4] <= mul_stage[2] >>> 12;
        x_pipeline[7]      <= x_pipeline[6];
        x2_pipeline[7]     <= x2_pipeline[6];
        valid_pipeline[7]  <= valid_pipeline[6];

        // Stage 5
        result_pipeline[5] <= result_pipeline[4] + A2;
        x_pipeline[8]      <= x_pipeline[7];
        x2_pipeline[8]     <= x2_pipeline[7];
        valid_pipeline[8]  <= valid_pipeline[7];

        // Stage 6
        mul_stage[3]       <= $signed(result_pipeline[5]) * $signed(x2_pipeline[8]);
        x_pipeline[9]      <= x_pipeline[8];
        x2_pipeline[9]     <= x2_pipeline[8];
        valid_pipeline[9]  <= valid_pipeline[8];

        result_pipeline[6] <= mul_stage[3] >>> 12;
        x_pipeline[10]     <= x_pipeline[9];
        x2_pipeline[10]    <= x2_pipeline[9];
        valid_pipeline[10] <= valid_pipeline[9];

        // Stage 7
        result_pipeline[7] <= result_pipeline[6] + A1;
        x_pipeline[11]     <= x_pipeline[10];
        x2_pipeline[11]    <= x2_pipeline[10];
        valid_pipeline[11] <= valid_pipeline[10];

        // Stage 8
        mul_stage[4]       <= $signed(result_pipeline[7]) * $signed(x2_pipeline[11]);
        x_pipeline[12]     <= x_pipeline[11];
        x2_pipeline[12]    <= x2_pipeline[11];
        valid_pipeline[12] <= valid_pipeline[11];

        result_pipeline[8] <= mul_stage[4] >>> 12;
        x_pipeline[13]     <= x_pipeline[12];
        x2_pipeline[13]    <= x2_pipeline[12];
        valid_pipeline[13] <= valid_pipeline[12];

        // Stage 9
        result_pipeline[9] <= result_pipeline[8] + A0;
        x_pipeline[14]     <= x_pipeline[13];
        x2_pipeline[14]    <= x2_pipeline[13];
        valid_pipeline[14] <= valid_pipeline[13];

        // Stage 10
        mul_stage[5]       <= $signed(result_pipeline[9]) * $signed(x2_pipeline[14]);
        x_pipeline[15]     <= x_pipeline[14];
        valid_pipeline[15] <= valid_pipeline[14];

        result_pipeline[10] <= mul_stage[5] >>> 12;
        x_pipeline[16]      <= x_pipeline[15];
        valid_pipeline[16]  <= valid_pipeline[15];

        // Stage 11
        mul_stage[6]       <= $signed(result_pipeline[10]) * $signed(x_pipeline[16]);
        x_pipeline[17]     <= x_pipeline[16];
        valid_pipeline[17] <= valid_pipeline[16];

        result_pipeline[11] <= mul_stage[6] >>> 12;
        x_pipeline[18]      <= x_pipeline[17];
        valid_pipeline[18]  <= valid_pipeline[17];

        // Stage 12
        result_pipeline[12] <= result_pipeline[11] + x_pipeline[18];
        valid_pipeline[19]  <= valid_pipeline[18];
    end
end

assign o_fx    = result_pipeline[12];
assign o_valid = valid_pipeline[19];
assign o_ready = i_ready;

endmodule
