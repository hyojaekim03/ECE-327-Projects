/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 1 - Part 3                                  */
/* Shift-Left, Add, Subract ALU module             */
/***************************************************/

module alu # (
    parameter DATAW = 2 // Bitwidth of ALU operands
)(
    input  clk,                   // Input clock signal
    input  [DATAW-1:0] i_dataa,   // First operand (A)
    input  [DATAW-1:0] i_datab,   // Second operand (B)
    input  [1:0] i_op,            // Operation code (00: reset, 01: A << B, 10: A + B, 11: A - B)
    output [2*DATAW-1:0] o_result // ALU output
);

// Remember that you are required to register all inputs and outputs of the ALU and use 
// the adder/subtractor module you implemented in Part 2 of this lab.

/******* Your code starts here *******/
logic [DATAW:0] add_sub_result; // Store output from add_sub block
logic [2*DATAW-1:0] alu_result; // Store final result from alu block

logic [DATAW-1:0] reg_a; 
logic [DATAW-1:0] reg_b;
logic [1:0] iop;

// Clock inputs and outputs to registers
always_ff @ (posedge clk) begin
    reg_a = i_dataa;
    reg_b = i_datab;
    iop = i_op;
end

// Instantiate add_sub block
add_sub # (DATAW) add (.i_dataa(reg_a), .i_datab(reg_b), .i_op(iop[0]), .o_result(add_sub_result));

always_ff @ (posedge clk) begin
    if (iop == 2'b00) begin // reset
        alu_result = 0;
    end else if (iop == 2'b01) begin // shift left
        alu_result = reg_a << reg_b; 
    end else begin // add or aubstract
        alu_result = {{(DATAW-1){add_sub_result[DATAW]}}, add_sub_result};
    end
end

assign o_result = alu_result;

/******* Your code ends here ********/

endmodule
