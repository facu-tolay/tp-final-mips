module pipeline_top
#(
    parameter NB_DATA = 32,
    parameter NB_REG = 5
)
(
    input wire                              i_clock             ,
    input wire                              i_reset             ,
    input wire                              i_valid             ,
    input wire                              i_execution_mode    ,
    input wire                              i_step              ,

    output wire [NB_DATA         -1 : 0]     o_pc                ,
    output wire [NB_DATA*NB_DATA  -1 : 0]     o_registros         ,
    output wire [NB_DATA         -1 : 0]     o_registro          ,
    output wire [NB_DATA         -1 : 0]     o_data_memory       ,
    output wire [NB_DATA         -1 : 0]     o_ciclos            ,
    output wire [4:0]                       o_n_reg             ,
    output wire                             o_halt
);

    reg  [NB_DATA-1 : 0] pc_salto;
    wire [NB_DATA-1 : 0] pc_4;
    wire [NB_DATA-1 : 0] pc_4_d;
    wire [NB_DATA-1 : 0] pc_4_e;
    wire [NB_DATA-1 : 0] pc_4_m;

    wire [NB_DATA-1 : 0] instruccion;
    wire [4         : 0] rs;
    wire [4         : 0] rs_d;
    wire [4         : 0] rt;
    wire [4         : 0] rt_d;
    wire [4         : 0] rd;
    wire [4         : 0] sa;
    wire [25        :0]  instr_index;
    wire [5         :0]  opcode;
    wire [5         :0]  opcode_e;
    wire [NB_DATA-1:0] extended;
    wire [4:0]  write_reg;
    wire [NB_DATA-1:0] write_data;
    wire [4:0]  write_reg_wb;
    wire [NB_DATA-1:0] write_data_wb;
    wire [NB_DATA-1:0] pc_branch;
    wire [NB_DATA-1:0] pc_jump;
    wire [NB_DATA-1:0] read_data_1;
    wire [NB_DATA-1:0] read_data_2;
    wire [NB_DATA-1:0] read_data_2_e;
    reg  [NB_DATA-1:0] datoB;
    wire [4:0]  rt_rd;
    wire [4:0]  rt_rd_m;
    wire [NB_DATA-1:0] aluResult;
    wire [NB_DATA-1:0] alu_result;
    wire        zero;
    wire [NB_DATA-1:0] data_memory;
    wire [NB_DATA-1:0] count;

    wire [2:0] aluop;
    wire       alusrc;
    wire       regdst;
    wire       branch;
    wire       memrd;
    wire       memwr;
    wire       memtoreg;
    wire       regwr;
    wire [1:0] jump;
    wire [1:0] jump_e;
    wire [1:0] jump_m;
    wire       flush;
    wire       flush_d;
    wire       flush_m;
    wire       pc_src;

    wire branch_e;
    wire memrd_e;
    wire memwr_e;
    wire memtoreg_e;
    wire regwr_e;
    wire memtoreg_m;
    wire regwr_m;
    wire memtoreg_w;

    wire halt;
    wire halt_f;
    wire halt_d;
    wire halt_e;
    wire halt_m;
    wire stop;
    wire stall;

    wire [1:0] muxA;
    wire [1:0] muxB;

    wire [1023:0] registros;

    // --------------------------------------------------
    // Logic block
    // --------------------------------------------------
    always@(*)begin
        if(i_valid) begin
            if(pc_src) begin
                pc_salto = pc_branch;
            end
            else begin
                pc_salto = pc_jump;
            end
        end
    end 

    // --------------------------------------------------
    // Fetch stage
    // --------------------------------------------------
    fetch_stage u_fetch_stage
    (
        .o_pc_next          (pc_4               ),
        .o_instruction      (instruccion        ),
        .o_rs               (rs                 ),
        .o_rt               (rt                 ),
        .o_halt             (halt_f             ),

        .i_execution_mode   (i_execution_mode   ),
        .i_step             (i_step             ),
        .i_halt             (1'b0               ),
        .i_stall            (stall              ),
        .i_pc_next          (pc_salto           ),
        .i_pc_src           (1'b0               ),
        .i_valid            (i_valid            ),
        .i_clock            (i_clock            ),
        .i_reset            (i_reset            )
    );

    // --------------------------------------------------
    // Decode stage
    // --------------------------------------------------
    assign flush = flush_d || flush_m;

    decode_stage u_decode_stage
    (
        // i_write_data,
        // i_write_reg,
        // i_reg_write,
        .o_pc_jump              (pc_jump                ),
        .o_registros            (                       ), // FIXME
        .o_alu_op               (aluop                  ),
        .o_alu_src              (alusrc                 ),
        .o_reg_dst              (regdst                 ),
        .o_branch               (branch                 ),
        .o_jump                 (jump                   ),
        .o_flush                (flush_d                ),
        .o_mem_read             (memrd                  ),
        .o_mem_write            (memwr                  ),
        .o_mem_to_reg           (memtoreg               ),
        .o_reg_write            (regwr                  ),
        .o_halt                 (halt_d                 ),
        .o_stall                (stall                  ),
        .o_rs                   (rs_d                   ),
        .o_rd                   (rd                     ),
        .o_rt                   (rt_d                   ),
        .o_sa                   (sa                     ),
        .o_opcode               (opcode                 ),
        .o_pc_next              (pc_4_d                 ),
        .o_data_read_reg_0      (read_data_1            ),
        .o_data_read_reg_1      (read_data_2            ),
        .o_extended             (extended               ),

        .i_instruction          (instruccion            ),
        .i_pc_next              (pc_4                   ), // FIXME creo que este pc_4 deberia ponerse como (pc_4 - 32'h1)
        .i_data_reg_write       (                       ),
        .i_data_reg_write_sel   (                       ),
        .i_write_reg_enable     (                       ),
        .i_halt                 (halt_f                 ),
        .i_step                 (i_step                 ),
        .i_flush                (flush                  ),
        .i_execution_mode       (i_execution_mode       ),
        .i_rt_index             (rt                     ),
        .i_valid                (i_valid                ),
        .i_reset                (i_reset                ),
        .i_clock                (i_clock                )
    );

    // --------------------------------------------------
    // Execution stage
    // --------------------------------------------------
    execute_stage u_execute_stage
    (
        .o_branch               (branch_e               ),
        .o_mem_read             (memrd_e                ),
        .o_mem_write            (memwr_e                ),
        .o_jump                 (jump_e                 ),
        .o_mem_to_reg           (memtoreg_e             ),
        .o_reg_write            (regwr_e                ),
        .o_pc_branch            (pc_branch              ),
        .o_alu_result           (aluResult              ),
        .o_halt                 (halt_e                 ),
        .o_opcode               (opcode_e               ),
        .o_pc_4                 (pc_4_e                 ),
        .o_read_data_2          (read_data_2_e          ),
        .o_rt_rd                (rt_rd                  ),
        .o_zero                 (zero                   ),

        .i_alu_op               (aluop                  ),
        .i_alu_src              (alusrc                 ),
        .i_reg_dst              (regdst                 ),
        .i_branch               (branch                 ),
        .i_jump                 (jump                   ),
        .i_mem_read             (memrd                  ),
        .i_mem_write            (memwr                  ),
        .i_mem_to_reg           (memtoreg               ),
        .i_reg_write            (regwr                  ),
        .i_halt                 (halt_d                 ),
        .i_pc_4                 (pc_4_d                 ),
        .i_read_data_1          (read_data_1            ),
        .i_read_data_2          (read_data_2            ),
        .i_extended             (extended               ),
        .i_opcode               (opcode                 ),
        .i_alu_result           (aluResult              ),
        .i_data_memory          (write_data             ),
        .i_execution_mode       (i_execution_mode       ),
        .i_step                 (i_step                 ),
        .i_rd                   (rd                     ),
        .i_rt                   (rt_d                   ),
        .i_sa                   (sa                     ),
        .i_mux_A                (muxA                   ),
        .i_mux_B                (muxB                   ),
        .i_flush                (flush_m                ),
        .i_valid                (i_valid                ),
        .i_reset                (i_reset                ),
        .i_clock                (i_clock                )
    );

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_pc             = pc_4 - 1'b1;
    assign o_registros      = registros;
    assign o_data_memory    = data_memory;
    assign o_ciclos         = count;
    assign o_halt           = halt;

endmodule
