/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* MVM Control FSM                                 */
/***************************************************/

module ctrl # (
    parameter VEC_ADDRW = 8,
    parameter MAT_ADDRW = 9,
    parameter VEC_SIZEW = VEC_ADDRW + 1,
    parameter MAT_SIZEW = MAT_ADDRW + 1
    
)(
    input  clk,
    input  rst,
    input  start,
    input  [VEC_ADDRW-1:0] vec_start_addr,
    input  [VEC_SIZEW-1:0] vec_num_words,
    input  [MAT_ADDRW-1:0] mat_start_addr,
    input  [MAT_SIZEW-1:0] mat_num_rows_per_olane,
    output [VEC_ADDRW-1:0] vec_raddr,
    output [MAT_ADDRW-1:0] mat_raddr,
    output accum_first,
    output accum_last,
    output ovalid,
    output busy
);

/******* Your code starts here *******/
enum {IDLE, COMPUTE} state, next_state;

//pipeline regs
logic valid_pipe;

//Input regs
logic [VEC_ADDRW-1:0] r_vec_base_addr;
logic [MAT_ADDRW-1:0] r_mat_base_addr;
logic [VEC_SIZEW-1:0] r_num_vec_words;
logic [MAT_SIZEW-1:0] r_num_rows; 

//Counters
logic [VEC_SIZEW-1:0] vec_idx;
logic [MAT_SIZEW-1:0] row_idx;

//Pipelined Values
logic [VEC_SIZEW-1:0] vec_idx_pipe [2:0];
logic [MAT_SIZEW-1:0] row_idx_pipe [2:0];
logic [MAT_ADDRW-1:0] r_mat_raddr_pipe [2:0];
logic r_ovalid_pipe [2:0];

//Output regs
logic [VEC_ADDRW-1:0] r_vec_raddr;
logic [MAT_ADDRW-1:0] r_mat_raddr;
logic r_accum_first;
logic r_accum_last;
logic r_ovalid;
logic r_busy;

integer i;

always_ff @(posedge clk) begin
    if (rst) begin 
        state               <= IDLE; 
        r_vec_base_addr     <= 0;
        r_mat_base_addr     <= 0;
        r_num_vec_words     <= 0;
        r_num_rows          <= 0; 
        vec_idx             <= 0; 
        row_idx             <= 0;
        
        valid_pipe <= 0;

    end else begin 
        state               <= next_state;
        
        if (state == IDLE) begin
            r_vec_base_addr     <= vec_start_addr;
            r_mat_base_addr     <= mat_start_addr;
            r_num_vec_words     <= vec_num_words;
            r_num_rows          <= mat_num_rows_per_olane;
            
            r_vec_raddr   = 0;
            r_mat_raddr   = 0;
            r_accum_first = 0;
            r_accum_last  = 0;
            r_ovalid      = 0;
            r_busy        = 0;
            
        end else begin
            if (vec_idx == r_num_vec_words - 1) begin
                vec_idx         <= 0;
                row_idx         <= row_idx + 1;
            end else begin
                vec_idx         <= vec_idx + 1;
            end
            
            vec_idx_pipe[0]     <= vec_idx;
            row_idx_pipe[0]     <= row_idx;
            r_ovalid            <= 1;
            r_ovalid_pipe[0]    <= r_ovalid;
            
            for (i = 1; i < 3; i = i + 1) begin
                vec_idx_pipe[i]     <= vec_idx_pipe[i-1];
                row_idx_pipe[i]     <= vec_idx_pipe[i-1];
                r_ovalid_pipe[i]    <= r_ovalid_pipe[i-1];
            end
            

            r_mat_raddr_pipe[0] <= row_idx * r_num_vec_words;
            r_mat_raddr_pipe[1] <= r_mat_raddr_pipe[0] + vec_idx_pipe[0];
            r_mat_raddr_pipe[2] <= r_mat_raddr_pipe[1] + r_mat_base_addr;
            r_mat_raddr         <= r_mat_raddr_pipe[2];
            
            r_vec_raddr         <= r_vec_base_addr + vec_idx_pipe[2];
            
            r_accum_first       <= (vec_idx_pipe[2] == 0);
            r_accum_last        <= (vec_idx_pipe[2] == r_num_vec_words - 1);
            r_busy              <= 1;

        end 

        valid_pipe <= r_ovalid_pipe[2];
        
    end 
end

always_comb begin: state_decoder
  case (state)
    IDLE : 
        next_state = (start) ? COMPUTE : IDLE;
        
    COMPUTE : 
        next_state = ((row_idx == r_num_rows) && (vec_idx == r_num_vec_words-1)) ? IDLE : COMPUTE;
        
    default: next_state = IDLE;
  endcase 
end

assign vec_raddr    = r_vec_raddr;
assign mat_raddr    = r_mat_raddr;
assign accum_first  = r_accum_first;
assign accum_last   = r_accum_last; 
assign ovalid       = valid_pipe;
assign busy         = r_busy;
/******* Your code ends here ********/

endmodule