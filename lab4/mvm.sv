/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* Matrix Vector Multiplication (MVM) Module       */
/***************************************************/

module mvm # (
    parameter IWIDTH = 8,
    parameter OWIDTH = 32,
    parameter MEM_DATAW = IWIDTH * 8,
    parameter VEC_MEM_DEPTH = 256,
    parameter VEC_ADDRW = $clog2(VEC_MEM_DEPTH),
    parameter MAT_MEM_DEPTH = 512,
    parameter MAT_ADDRW = $clog2(MAT_MEM_DEPTH),
    parameter NUM_OLANES = 8
)(
    input clk,
    input rst,
    input [MEM_DATAW-1:0] i_vec_wdata,
    input [VEC_ADDRW-1:0] i_vec_waddr,
    input i_vec_wen,
    input [MEM_DATAW-1:0] i_mat_wdata,
    input [MAT_ADDRW-1:0] i_mat_waddr,
    input [NUM_OLANES-1:0] i_mat_wen,
    input i_start,
    input [VEC_ADDRW-1:0] i_vec_start_addr,
    input [VEC_ADDRW:0] i_vec_num_words,
    input [MAT_ADDRW-1:0] i_mat_start_addr,
    input [MAT_ADDRW:0] i_mat_num_rows_per_olane,
    output o_busy,
    output [OWIDTH-1:0] o_result [0:NUM_OLANES-1],
    output o_valid
);

/******* Your code starts here *******/

logic i_valid_dot;
logic o_valid_dot [0:NUM_OLANES-1];
logic [OWIDTH-1:0] dot_result [0:NUM_OLANES-1];

logic [VEC_ADDRW-1:0] r_vec_raddr;
logic [MAT_ADDRW-1:0] r_mat_raddr;
logic [MEM_DATAW-1:0] r_vec_data;
logic [MEM_DATAW-1:0] r_mat_data [0:NUM_OLANES-1];
logic r_accum_first;
logic r_accum_last;

mem # (
    .DATAW(MEM_DATAW),
    .DEPTH(VEC_MEM_DEPTH),
    .ADDRW(VEC_ADDRW)
) vec_mem (
    .clk(clk),
    .wdata(i_vec_wdata),
    .waddr(i_vec_waddr),
    .wen(i_vec_wen),
    .raddr(r_vec_raddr),
    .rdata(r_vec_data)
);

ctrl # (
    .VEC_ADDRW(VEC_ADDRW),
    .MAT_ADDRW(MAT_ADDRW),
    .VEC_SIZEW(VEC_ADDRW + 1),
    .MAT_SIZEW(MAT_ADDRW + 1)
) mvn_ctrl (
    .clk(clk),
    .rst(rst),
    .start(i_start),
    .vec_start_addr(i_vec_start_addr),
    .vec_num_words(i_vec_num_words),
    .mat_start_addr(i_mat_start_addr),
    .mat_num_rows_per_olane(i_mat_num_rows_per_olane),
    .vec_raddr(r_vec_raddr),
    .mat_raddr(r_mat_raddr),
    .accum_first(r_accum_first),
    .accum_last(r_accum_last),
    .ovalid(i_valid_dot),
    .busy(o_busy)
);

genvar i;
generate
for (i = 0; i < NUM_OLANES; i=i+1) begin:
    gen_matrix_mem
        mem # (
            .DATAW(MEM_DATAW),
            .DEPTH(MAT_MEM_DEPTH),
            .ADDRW(MAT_ADDRW)
        ) matrix_mem (
            .clk(clk),
            .wdata(i_mat_wdata),
            .waddr(i_mat_waddr),
            .wen(i_mat_wen[i]),
            .raddr(r_mat_raddr),
            .rdata(r_mat_data[i])
        );
end
endgenerate

genvar j;
generate
for (j = 0; j < NUM_OLANES; j=j+1 ) begin:
    gen_matrix_dot
        dot8 # (
            .IWIDTH(IWIDTH),
            .OWIDTH(OWIDTH)
        ) dot_unit (
            .clk(clk),
            .rst(rst),
            .vec0(r_vec_data),
            .vec1(r_mat_data[j]),
            .ivalid(i_valid_dot),
            .result(dot_result[j]),
            .ovalid(o_valid_dot[j])
        );
end
endgenerate

genvar k;
generate
for (k = 0; k < NUM_OLANES; k=k+1 )begin:
    gen_matrix_accum
        accum # (
            .DATAW(OWIDTH),
            .ACCUMW(OWIDTH)
        ) accum_unit (
            .clk(clk),
            .rst(rst),
            .data(dot_result[k]),
            .ivalid(o_valid_dot[k]),
            .first(r_accum_first),
            .last(r_accum_last),
            .result(o_result[k]),
            .ovalid(o_valid)
        );
end
endgenerate

always_ff @ (posedge clk) begin
    if (rst) begin
       ova
    end
end

/******* Your code ends here ********/

endmodule