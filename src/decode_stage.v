
module decode_stage
#(
    parameter NB_DATA               = 32  ,
    parameter NB_REGISTER           = 5   ,
    parameter NB_OPCODE             = 6   ,
    parameter NB_INSTRUCTION_INDEX  = 26
)
(
    output wire [NB_REGISTER    -1 : 0] o_rs                   ,
    output wire [NB_REGISTER    -1 : 0] o_rd                   ,
    output wire [NB_REGISTER    -1 : 0] o_rt                   ,
    output wire [NB_REGISTER    -1 : 0] o_sa                   ,
    output wire [NB_OPCODE      -1 : 0] o_opcode               ,
    output wire [NB_DATA        -1 : 0] o_pc_next              ,
    output wire [NB_DATA        -1 : 0] o_data_read_reg_0      ,
    output wire [NB_DATA        -1 : 0] o_data_read_reg_1      ,
    output wire [NB_DATA        -1 : 0] o_extended             ,

    output wire [NB_DATA        -1 : 0] o_pc_jump              ,
    output wire [NB_DATA*NB_DATA-1 : 0] o_registros            ,

    output wire [2              -1 : 0] o_alu_op               ,
    output wire                         o_alu_src              ,
    output wire                         o_reg_dst              ,
    output wire                         o_branch               ,
    output wire [2              -1 : 0] o_jump                 ,
    output wire                         o_flush                ,
    output wire                         o_mem_read             ,
    output wire                         o_mem_write            ,
    output wire                         o_mem_to_reg           ,
    output wire                         o_reg_write            ,
    output wire                         o_halt                 ,
    output wire                         o_stall                ,

    input wire [NB_DATA         -1 : 0] i_instruction          ,
    input wire [NB_DATA         -1 : 0] i_pc_next              ,
    input wire [NB_DATA         -1 : 0] i_data_reg_write       ,
    input wire [NB_REGISTER     -1 : 0] i_data_reg_write_sel   ,
    input wire                          i_write_reg_enable     ,
    input wire                          i_halt                 ,
    input wire                          i_flush                ,
    input wire                          i_execution_mode       ,
    input wire                          i_step                 ,
    input wire [NB_REGISTER     -1 : 0] i_rt_index             ,
    input wire                          i_valid                ,
    input wire                          i_reset                ,
    input wire                          i_clock
);

    wire [NB_DATA       -1  : 0]    data_read_reg_0;
    wire [NB_DATA       -1  : 0]    data_read_reg_1;
    wire                            fetch_new_instruction;
    wire [NB_DATA       -1  : 0]    pc_jump;

    reg  [NB_DATA               -1  : 0]    instruction;
    reg  [NB_DATA               -1  : 0]    pc_next;
    reg  [NB_REGISTER           -1  : 0]    rs;
    reg  [NB_REGISTER           -1  : 0]    rt;
    reg  [NB_REGISTER           -1  : 0]    rd;
    reg  [NB_REGISTER           -1  : 0]    sa;
    reg  [NB_DATA               -17 : 0]    offset;
    reg  [NB_DATA               -1  : 0]    data_reg_write;
    reg  [NB_INSTRUCTION_INDEX  -1  : 0]    instruction_index;
    reg                                     halt;
    reg                                     halt_out;

    reg  [2     -1 : 0] alu_op_out;
    reg                 alu_src_out;
    reg                 reg_dst_out;
    reg                 branch_out;
    reg  [2     -1 : 0] jump_out;
    reg                 flush_out;
    reg                 mem_read_out;
    reg                 mem_write_out;
    reg                 mem_to_reg_out;
    reg                 reg_write_out;

    wire [2     -1 : 0] alu_op;
    wire                alu_src;
    wire                reg_dst;
    wire                branch;
    wire [2     -1 : 0] jump;
    wire                flush;
    wire                mem_read;
    wire                mem_write;
    wire                mem_to_reg;
    wire                reg_write;

    assign fetch_new_instruction = ~i_execution_mode || (i_execution_mode && i_step);

    // --------------------------------------------------
    // Halt block
    // --------------------------------------------------
    always @(posedge i_clock) begin : halt_block
        if(i_reset) begin
            halt <= 1'b0;
        end
        else if(i_valid) begin
            if (fetch_new_instruction) begin
                halt <= i_halt;
            end
        end
    end

    always @ (negedge i_clock) begin : halt_out_block
        if(i_reset) begin
            halt_out <= 1'b0;
        end
        else if(i_valid) begin
            if (fetch_new_instruction) begin
                if(o_stall || i_flush) begin
                    halt_out <= 1'b0;
                end
                else begin
                    halt_out <= halt;
                end
            end
        end
    end

    // --------------------------------------------------
    // Next PC delay
    // --------------------------------------------------
    always @(posedge i_clock) begin: reg_pc_next
        if(i_reset) begin
            pc_next <= 32'b0;
        end
        else if(i_valid) begin
            if(fetch_new_instruction) begin
                pc_next <= i_pc_next;
            end
        end
    end

    // --------------------------------------------------
    // Instruction delay
    // --------------------------------------------------
    always @(posedge i_clock) begin: reg_instruction
        if(i_reset) begin
            instruction <= 32'b0;
        end
        else if(i_valid) begin
            if(fetch_new_instruction) begin
                instruction <= i_instruction;
            end
        end
    end

    // --------------------------------------------------
    // Intruction fields
    // --------------------------------------------------
    always @(negedge i_clock) begin : reg_rs
        if(i_reset) begin
            rs <= 5'b0;
        end
        if(i_valid) begin
            if(fetch_new_instruction) begin
                rs <= instruction[25:21];
            end
        end
    end

    always @(negedge i_clock) begin : reg_rt
        if(i_reset) begin
            rt <= 5'b0;
        end
        if(i_valid) begin
            if(fetch_new_instruction) begin
                rt <= instruction[20:16];
            end
        end
    end

    always @(negedge i_clock) begin : reg_rd
        if(i_reset) begin
            rd <= 5'b0;
        end
        if(i_valid) begin
            if(fetch_new_instruction) begin
                rd <= instruction[15:11];
            end
        end
    end

    always @(negedge i_clock) begin : reg_sa
        if(i_reset) begin
            sa <= 5'b0;
        end
        if(i_valid) begin
            if(fetch_new_instruction) begin
                sa <= instruction[10:6];
            end
        end
    end

    always @(negedge i_clock) begin : reg_offset
        if(i_reset) begin
            offset <= 16'b0;
        end
        if(i_valid) begin
            if(fetch_new_instruction) begin
                offset <= instruction[15:0];
            end
        end
    end

    always @(negedge i_clock) begin : reg_instruction_branch_index
        if(i_reset) begin
            instruction_index <= 26'b0;
        end
        if(i_valid) begin
            if(fetch_new_instruction) begin
                instruction_index <= instruction[25:0];
            end
        end
    end

    // --------------------------------------------------
    // Register data write
    // --------------------------------------------------
    always @(negedge i_clock) begin : data_reg_write_block
        if(i_reset) begin
            data_reg_write <= 32'b0;
        end
        if(i_valid) begin
            data_reg_write <= i_data_reg_write;
        end
    end

    // --------------------------------------------------
    // Register bank
    // --------------------------------------------------
    register_bank u_register_bank
    (
        .o_data_read_reg_0  (data_read_reg_0        ),
        .o_data_read_reg_1  (data_read_reg_1        ),

        .i_read_reg_sel_0   (rs                     ),
        .i_read_reg_sel_1   (rt                     ),
        .i_write_reg_sel    (i_data_reg_write_sel   ),
        .i_write_reg_data   (data_reg_write         ),
        .i_write_reg_enable (i_write_reg_enable     ),
        .i_valid            (i_valid                ),
        .i_reset            (i_reset                ),
        .i_clock            (i_clock                )
    );

    // --------------------------------------------------
    // Control unit
    // --------------------------------------------------
    control_unit u_control_unit
    (
        .o_alu_op           (alu_op                 ),
        .o_alu_src          (alu_src                ),
        .o_reg_dst          (reg_dst                ),
        .o_branch           (branch                 ),
        .o_mem_read         (mem_read               ),
        .o_mem_write        (mem_write              ),
        .o_mem_to_reg       (mem_to_reg             ),
        .o_reg_write        (reg_write              ),
        .o_jump             (jump                   ),
        .o_flush            (flush                  ),
        .o_opcode           (o_opcode               ),

        .i_instruction      (instruction            ),
        .i_valid            (i_valid                ),
        .i_reset            (i_reset                ),
        .i_clock            (i_clock                )
    );

    // --------------------------------------------------
    // Control unit output signals
    // --------------------------------------------------
    always @ (negedge i_clock) begin : control_unit_outputs
        if(i_reset) begin
            alu_op_out      <= 2'b0;
            alu_src_out     <= 1'b0;
            reg_dst_out     <= 1'b0;
            branch_out      <= 1'b0;
            jump_out        <= 2'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            reg_write_out   <= 1'b0;
            flush_out       <= 1'b0;
        end
        if(i_valid) begin
            if(fetch_new_instruction) begin
                if(o_stall || i_flush) begin
                    alu_op_out      <= 2'b0;
                    alu_src_out     <= 1'b0;
                    reg_dst_out     <= 1'b0;
                    branch_out      <= 1'b0;
                    jump_out        <= 2'b0;
                    flush_out       <= 1'b0;
                    mem_read_out    <= 1'b0;
                    mem_write_out   <= 1'b0;
                    mem_to_reg_out  <= 1'b0;
                    reg_write_out   <= 1'b0;
                end
                else begin
                    alu_op_out     <= alu_op;
                    alu_src_out    <= alu_src;
                    reg_dst_out    <= reg_dst;
                    branch_out     <= branch;
                    jump_out       <= jump;
                    flush_out      <= flush;
                    mem_read_out   <= mem_read;
                    mem_write_out  <= mem_write;
                    mem_to_reg_out <= mem_to_reg;
                    reg_write_out  <= reg_write;
                end
            end
        end
    end

    // --------------------------------------------------
    // Hazard detection unit
    // --------------------------------------------------
    hazard_detection_unit u_hazard_detection_unit
    (
        .o_stall            (o_stall                ),

        .i_mem_read_index   (o_mem_read             ),
        .i_rt_index         (i_rt_index             ),
        .i_rt_ifid          (rt                     ),
        .i_rs_ifid          (rs                     )
    );

    // --------------------------------------------------
    // Branch PC calculation for jumps
    // --------------------------------------------------
    branch_pc_calculator u_branch_pc_calculator
    (
        .o_pc_jump              (pc_jump                ),

        .i_jump                 (jump                   ),
        .i_pc_next              (i_pc_next              ),
        .i_read_data            (data_read_reg_0        ),
        .i_instruction_index    (instruction_index      )
    );


    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_pc_next            = pc_next;
    assign o_pc_jump            = pc_jump;
    assign o_halt               = halt_out;

    assign o_rs                 = rs;
    assign o_rt                 = rt;
    assign o_rd                 = rd;
    assign o_sa                 = sa;

    assign o_extended           = {{(NB_DATA-16){offset[15]}}, offset};

    assign o_alu_op             = alu_op_out;
    assign o_alu_src            = alu_src_out;
    assign o_reg_dst            = reg_dst_out;
    assign o_branch             = branch_out;
    assign o_jump               = jump_out;
    assign o_mem_read           = mem_read_out;
    assign o_mem_write          = mem_write_out;
    assign o_mem_to_reg         = mem_to_reg_out;
    assign o_reg_write          = reg_write_out;
    assign o_flush              = flush_out;

    assign o_data_read_reg_0    = data_read_reg_0;
    assign o_data_read_reg_1    = data_read_reg_1;

endmodule
