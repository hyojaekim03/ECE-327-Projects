/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 1 - Part 2                                  */
/* Multi-bit adder/subtractor module               */
/***************************************************/

module add_sub # (
    parameter DATAW = 2 // Bitwidth of adder/subtractor operands
)(
    input [DATAW-1:0] i_dataa, // First operand (A)
    input [DATAW-1:0] i_datab, // Second operand (B)
    input i_op,                // Operation (0: A+B, 1: A-B)
    output [DATAW:0] o_result  // Addition/Subtraction result
);

/******* Your code starts here *******/
logic [DATAW:0] final_result;
logic [DATAW+1:0] carry_in;
assign carry_in[0] = i_op;

genvar i;
generate 
for (i = 0; i < DATAW; i = i+1)
begin: gen_adders 
    full_adder add_inst(
        .a(i_dataa[i]), .b(i_datab[i] ^ i_op), .cin(carry_in[i]), .s(final_result[i]), .cout(carry_in[i+1])
    );
end 
endgenerate 


full_adder # () final_add (.a(i_dataa[DATAW-1]), .b(i_datab[DATAW-1] ^ i_op), .cin(carry_in[DATAW]), .s(final_result[DATAW]), .cout(carry_in[DATAW+1])); 

assign o_result = final_result;
//assign o_result[DATAW] = last_val;

/******* Your code ends here ********/

endmodule
