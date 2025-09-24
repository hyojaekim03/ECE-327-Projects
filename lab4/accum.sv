/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* Accumulator Module                              */
/***************************************************/

module accum # (
    parameter DATAW = 32,
    parameter ACCUMW = 32
)(
    input  clk,
    input  rst,
    input  signed [DATAW-1:0] data,
    input  ivalid,
    input  first,
    input  last,
    output signed [ACCUMW-1:0] result,
    output ovalid
);

/******* Your code starts here *******/
// Internal registers
logic signed [ACCUMW-1:0] r_result;
logic r_ovalid;

always_ff @(posedge clk) begin
    if (rst) begin
        r_result <= 0;
        r_ovalid <= 0;
    end else begin
        if (ivalid) begin
            if (first)
                r_result <= data;
            else
                r_result <= r_result + data;

            r_ovalid <= last;
        end else begin
            r_ovalid <= 0;
        end
    end
end

// Output assignments
assign result = r_result;
assign ovalid = r_ovalid;; 

/******* Your code ends here ********/

endmodule