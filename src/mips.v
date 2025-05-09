`timescale 1ns / 1ps

module mips
#(
    parameter NB_DATA               = 32    ,
    parameter NB_BYTE               = 8     ,
    parameter NB_REG_ADDRESS        = 5     ,
    parameter NB_MEM_ADDRESS        = 7     ,
    parameter N_STAGES_TRANSITIONS  = 5     ,

    parameter NB_JUMP_ADDRESS       = 26    ,
    parameter NB_OP_FIELD           = 6     ,
    parameter NB_CONTROL_SIGNALS    = 18    ,
    parameter NB_ALU_OP_FIELD       = 3
)
(
    output wire [NB_DATA              - 1 : 0]   o_debug_read_reg                ,
    output wire [NB_DATA              - 1 : 0]   o_debug_read_mem                ,
    output wire [NB_DATA              - 1 : 0]   o_debug_read_pc                 ,
    output wire                                  o_is_program_end                ,

    input  wire [NB_REG_ADDRESS       - 1 : 0]   i_debug_read_reg_address        ,
    input  wire [NB_MEM_ADDRESS       - 1 : 0]   i_debug_read_mem_address        ,
    input  wire [N_STAGES_TRANSITIONS - 1 : 0]   i_enable_stages_transitions     ,
    input  wire [NB_BYTE              - 1 : 0]   i_load_program_byte             ,
    input  wire                                  i_load_program_write_enable     ,
    input  wire                                  i_pc_reset                      ,
    input  wire                                  i_delete_program                ,
    input  wire                                  i_reset                         ,
    input  wire                                  i_clock
);

    // --------------------------------------------------
    // Control signals definition
    // --------------------------------------------------
        //   17      16      15        14     13      12   11    10    9       8       7       6        5        4        3         2          1        0
        // RegDst MemToReg MemRead   Branch MemWrite Ope2 Ope1 Ope0 ALUSrc RegWrite ShiftSrc JmpSrc JReturnDst EQorNE DataMask1 DataMask0 IsUnsigned JmpOrBrch
        localparam REG_DST          = 17;
        localparam MEM_TO_REG       = 16;
        localparam MEM_READ         = 15;
        localparam BRANCH           = 14;
        localparam MEM_WRITE        = 13;
        localparam OP2              = 12;
        localparam OP1              = 11;
        localparam OP0              = 10;
        localparam ALU_SRC          =  9;
        localparam REG_WRITE        =  8;
        localparam SHIFT_SRC        =  7;
        localparam JMP_SRC          =  6;
        localparam J_RETURN_DST     =  5;
        localparam EQ_OR_NEQ        =  4;
        localparam DATA_MASK_1      =  3;
        localparam DATA_MASK_0      =  2;
        localparam IS_UNSIGNED      =  1;
        localparam JMP_OR_BRCH      =  0;


    // Instruction fetch signals
    wire [NB_DATA               -1 : 0] instruction;
    wire [NB_DATA               -1 : 0] pc_value;

    wire [NB_DATA               -1 : 0] next_pc;
    wire [NB_DATA               -1 : 0] mux_dir;
    wire [NB_DATA               -1 : 0] mux_pc_immediate;
    wire [NB_DATA               -1 : 0] pc_plus_branch_address;

    wire                                mux_eq_neq;
    wire                                eq_neq_condition;
    wire                                enable_mux_pc_immediate;
    wire                                instruction_fetch_flush;
    wire                                no_risk_detected;

    // Control Unit signals
    wire [NB_CONTROL_SIGNALS    -1 : 0] control_signals;

    // Instruction Decode signals
    wire [NB_DATA               -1 : 0] data_a_for_condition;
    wire [NB_DATA               -1 : 0] data_b_for_condition;
    wire [NB_DATA               -1 : 0] data_branch_address;
    wire [NB_JUMP_ADDRESS       -1 : 0] data_jump_address;
    wire [NB_DATA               -1 : 0] data_ra;
    wire [NB_DATA               -1 : 0] data_rb;
    wire [NB_DATA               -1 : 0] data_immediate_signed;
    wire [NB_REG_ADDRESS        -1 : 0] reg_select_address_rs;
    wire [NB_REG_ADDRESS        -1 : 0] reg_select_address_rd;
    wire [NB_REG_ADDRESS        -1 : 0] reg_select_address_rt;
    wire [NB_OP_FIELD           -1 : 0] control_unit_operation;

    // Excecution stage signals
    wire                                shift_source_d;
    wire                                register_destination_d;
    wire                                alu_source_d;
    wire [NB_ALU_OP_FIELD       -1 : 0] alu_operation_d;
    wire [NB_DATA               -1 : 0] ra_data_d;
    wire [NB_DATA               -1 : 0] rb_data_d;
    wire [NB_DATA               -1 : 0] sign_extender_data_d;
    wire [NB_REG_ADDRESS        -1 : 0] rt_address_d;
    wire [NB_REG_ADDRESS        -1 : 0] rd_address_d;

    wire [NB_DATA               -1 : 0] data_for_memory;
    wire [NB_DATA               -1 : 0] alu_result;
    wire [NB_REG_ADDRESS        -1 : 0] exec_reg_address;

    // Memory Access signals
    wire [NB_DATA               -1 : 0] data_from_memory;

    // Write Back signals
    wire [NB_DATA               -1 : 0] data_from_write_back;
    wire [NB_REG_ADDRESS        -1 : 0] address_from_write_back;

    // --------------------------------------------------
    // Stages transitions signals
    // --------------------------------------------------
        // Stage transition IF/ID signals
        wire [NB_DATA * 2       -1 : 0] signals_if_to_id;
        wire [NB_DATA           -1 : 0] pc_plus_4;
        wire [NB_DATA           -1 : 0] pc_plus_4_d;
        wire [NB_DATA           -1 : 0] instruction_d;
        wire [NB_OP_FIELD       -1 : 0] instruction_function_d;

        // Stage transition ID/EX signals
        wire [120               -1 : 0] signals_id_to_ex; // FIXME hacer localparam de este y todos los otros
        wire [120               -1 : 0] signals_id_to_ex_d;

        // Stage transition EX/MEM signals
        wire [76                -1 : 0] signals_ex_to_mem_d;
        wire [76                -1 : 0] signals_ex_to_mem; // FIXME param

        // Stage transition MEM/WB signals
        wire [39                -1 : 0] signals_mem_to_wb_d; // FIXME param
        wire [39                -1 : 0] signals_mem_to_wb;


    // --------------------------------------------------
    // Instruction Fetch stage
    // --------------------------------------------------
    instruction_fetch u_instruction_fetch
    (
        .o_instruction              (instruction                    ),
        .o_is_end                   (o_is_program_end               ),
        .o_pc_value                 (pc_value                       ),

        .i_pc_reset                 (i_pc_reset                     ),
        .i_stall                    (i_enable_stages_transitions[4] && no_risk_detected ),
        .i_next_pc                  (next_pc                        ),
        .i_is_jump_or_branch        (control_signals[JMP_OR_BRCH]   ),
        .i_load_program_write_enable(i_load_program_write_enable    ),
        .i_load_program_byte        (i_load_program_byte            ),
        .i_reset                    (i_reset || i_delete_program    ),
        .i_clock                    (i_clock                        )
    );

    assign o_debug_read_pc = pc_value;

    // --------------------------------------------------
    // Next PC adder
    // --------------------------------------------------
    assign pc_plus_4 = pc_value + 32'h4;

    // --------------------------------------------------
    // Stage transition registers IF/ID
    // --------------------------------------------------
    assign signals_if_to_id       = {instruction_d, pc_plus_4_d};
    assign instruction_function_d = instruction_d[NB_OP_FIELD-1 : 0];

    stage_transition
    #(
        .NB_DATA(NB_DATA)
    )
    u_stage_transition_if_to_id_pc_plus_4
    (
        .o_data     (pc_plus_4_d                                            ),

        .i_data     (pc_plus_4                                              ),
        .i_valid    (i_enable_stages_transitions[3] && no_risk_detected     ),
        .i_reset    (i_reset || i_pc_reset                                  ),
        .i_clock    (i_clock                                                )
    );

    stage_transition
    #(
        .NB_DATA(NB_DATA)
    )
    u_stage_transition_if_to_id_instruction
    (
        .i_clock    (i_clock                                                ),
        .i_reset    (i_reset || (i_enable_stages_transitions[3] && instruction_fetch_flush) || i_pc_reset ),
        .i_valid    (i_enable_stages_transitions[3] && no_risk_detected     ),
        .i_data     (instruction                                            ),
        .o_data     (instruction_d                                          )
    );

    // --------------------------------------------------
    // Stage transition muxes IF/ID
    // --------------------------------------------------
    assign eq_neq_condition        = data_a_for_condition != data_b_for_condition;
    assign mux_eq_neq              = control_signals[EQ_OR_NEQ] ? eq_neq_condition : ~eq_neq_condition;

    assign mux_dir                 = control_signals[JMP_SRC] ? {6'b0, data_jump_address} << 2 : data_a_for_condition;

    assign pc_plus_branch_address  = pc_plus_4_d + $signed(data_branch_address << 2);
    assign enable_mux_pc_immediate = mux_eq_neq && control_signals[BRANCH];
    assign mux_pc_immediate        = enable_mux_pc_immediate ? pc_plus_branch_address : pc_plus_4;

    assign next_pc                 = control_signals[JMP_OR_BRCH] ? mux_dir : mux_pc_immediate;

    // --------------------------------------------------
    // Hazard unit
    // --------------------------------------------------
    hazard_unit u_hazard_unit
    (
        .i_jump_branch      (control_signals[JMP_OR_BRCH]   ),
        .i_branch           (enable_mux_pc_immediate        ),
        .i_mem_read_id_ex   (signals_id_to_ex_d[4]          ),
        .i_rs_if_id         (reg_select_address_rs          ),
        .i_rt_if_id         (reg_select_address_rt          ),
        .i_rt_id_ex         (signals_id_to_ex_d[114 : 110]  ),
        .o_if_flush         (instruction_fetch_flush        ),
        .o_risk_detected    (stall_ctl                      ),
        .o_no_risk_detected (no_risk_detected               )
    );

    // --------------------------------------------------
    // Control unit
    // --------------------------------------------------
    control_unit u_control_unit
    (
        .i_function         (instruction_function_d         ),
        .i_operation        (control_unit_operation         ),
        .i_enable_control   (stall_ctl                      ),
        .o_control          (control_signals                )
    );

    // --------------------------------------------------
    // Instruction decode stage
    // --------------------------------------------------
    instruction_decode u_instruction_decode
    (
        // Data
        .o_data_ra                      (data_ra                        ),
        .o_data_rb                      (data_rb                        ),
        .o_data_immediate_signed        (data_immediate_signed          ),
        .o_reg_select_address_rs        (reg_select_address_rs          ),
        .o_reg_select_address_rt        (reg_select_address_rt          ),
        .o_reg_select_address_rd        (reg_select_address_rd          ),

        // EQ/NEQ condition for jump or branch
        .o_data_a_for_condition         (data_a_for_condition           ),
        .o_data_b_for_condition         (data_b_for_condition           ),

        // Jump and branch addresses
        .o_data_branch_address          (data_branch_address            ),
        .o_data_jump_address            (data_jump_address              ),

        // Intruccion
        .i_instruction                  (instruction_d                  ),

        // Forwarding
        .i_reg_enable_write_id_ex       (signals_id_to_ex_d[2]          ),
        .i_reg_enable_write_ex_mem      (signals_ex_to_mem_d[2]         ),
        .i_reg_enable_write_mem_wb      (signals_mem_to_wb_d[1]         ),
        .i_reg_address_rd_id_ex         (exec_reg_address               ),
        .i_reg_address_rd_ex_mem        (signals_ex_to_mem_d[75:71]     ),
        .i_reg_address_rd_mem_wb        (address_from_write_back        ),
        .i_data_from_execution_stage    (alu_result                     ),
        .i_data_from_memory_access      (data_from_memory               ),
        .i_data_from_write_back         (data_from_write_back           ),

        // For register bank
        .i_write_reg_data               (data_from_write_back           ),
        .i_write_reg_address            (address_from_write_back        ),

        // For return address
        .i_next_pc                      (pc_plus_4_d                    ),

        // Control unit signals
        .o_control_unit_operation       (control_unit_operation         ),
        .i_jump_or_branch               (control_signals[JMP_OR_BRCH]   ),

        // Debug
        .o_debug_read_reg               (o_debug_read_reg               ),
        .i_debug_read_reg_address       (i_debug_read_reg_address       ),

        .i_reset                        (i_reset || i_pc_reset          ),
        .i_clock                        (i_clock                        )
    );

    // --------------------------------------------------
    // Stage transition register for ID/EX
    // --------------------------------------------------
    assign signals_id_to_ex = { reg_select_address_rd                       ,
                                reg_select_address_rt                       ,
                                data_immediate_signed                       ,
                                data_rb                                     ,
                                data_ra                                     ,
                                control_signals[REG_DST]                    ,
                                control_signals[ALU_SRC]                    ,
                                control_signals[OP2 : OP0]                  ,
                                control_signals[SHIFT_SRC]                  ,
                                control_signals[DATA_MASK_1 : DATA_MASK_0]  ,
                                control_signals[MEM_WRITE]                  ,
                                control_signals[MEM_READ]                   ,
                                control_signals[IS_UNSIGNED]                ,
                                control_signals[REG_WRITE]                  ,
                                control_signals[MEM_TO_REG]                 ,
                                control_signals[J_RETURN_DST]               };

    assign rd_address_d           = signals_id_to_ex_d[119:115];
    assign rt_address_d           = signals_id_to_ex_d[114:110];
    assign sign_extender_data_d   = signals_id_to_ex_d[109: 78];
    assign rb_data_d              = signals_id_to_ex_d[77 : 46];
    assign ra_data_d              = signals_id_to_ex_d[45 : 14];
    assign register_destination_d = signals_id_to_ex_d[13     ];
    assign alu_source_d           = signals_id_to_ex_d[12     ];
    assign alu_operation_d        = signals_id_to_ex_d[11 :  9];
    assign shift_source_d         = signals_id_to_ex_d[8      ];

    stage_transition
    #(
        .NB_DATA(120)
    )
    u_stage_transition_id_to_ex
    (
        .i_clock                (i_clock                        ),
        .i_reset                (i_reset || i_pc_reset          ),
        .i_valid                (i_enable_stages_transitions[2] ),
        .i_data                 (signals_id_to_ex               ),
        .o_data                 (signals_id_to_ex_d             )
    );

    // --------------------------------------------------
    // Execution stage
    // --------------------------------------------------
    execution u_execution_stage
    (
        .i_shift_source         (shift_source_d                 ),
        .i_register_destination (register_destination_d         ),
        .i_alu_source           (alu_source_d                   ),
        .i_alu_operation        (alu_operation_d                ),
        .i_ra_data              (ra_data_d                      ),
        .i_rb_data              (rb_data_d                      ),
        .i_sign_extender_data   (sign_extender_data_d           ),
        .i_rt_address           (rt_address_d                   ),
        .i_rd_address           (rd_address_d                   ),
        .o_register_address     (exec_reg_address               ),
        .o_memory_data          (data_for_memory                ),
        .o_alu_result           (alu_result                     )
    );

    // --------------------------------------------------
    // Stage transition register for EX/MEM
    // --------------------------------------------------
    assign signals_ex_to_mem = { exec_reg_address           ,
                                 data_for_memory            ,
                                 alu_result                 ,
                                 signals_id_to_ex_d[7:5]    ,
                                 signals_id_to_ex_d[3:0]    };

    stage_transition
    #(
        .NB_DATA(76)
    )
    u_stage_transition_ex_to_mem
    (
        .i_clock                (i_clock                        ),
        .i_reset                (i_reset || i_pc_reset          ),
        .i_valid                (i_enable_stages_transitions[1] ),
        .i_data                 (signals_ex_to_mem              ),
        .o_data                 (signals_ex_to_mem_d            )
    );

    // --------------------------------------------------
    // Memory access stage
    // --------------------------------------------------
    memory_access u_memory_access
    (
        .i_data_write               (signals_ex_to_mem_d[70:39]     ),
        .i_data_mask                (signals_ex_to_mem_d[6:5]       ),
        .i_memory_to_register       (signals_ex_to_mem_d[1]         ),
        .i_is_unsigned              (signals_ex_to_mem_d[3]         ),
        .i_write_enable             (signals_ex_to_mem_d[4]         ),

        .i_memory_address           (signals_ex_to_mem_d[38:7]      ),
        .o_data                     (data_from_memory               ),

        .i_debug_read_mem_address   (i_debug_read_mem_address       ),
        .o_debug_read_mem           (o_debug_read_mem               ),

        .i_reset                    (i_reset|| i_pc_reset           ),
        .i_clock                    (i_clock                        )
    );

    // --------------------------------------------------
    // Stage transition register for MEM/WB
    // --------------------------------------------------
    assign signals_mem_to_wb = { signals_ex_to_mem_d[75:71]     ,
                                 data_from_memory               ,
                                 signals_ex_to_mem_d[2]         ,
                                 signals_ex_to_mem_d[0]         };

    stage_transition
    #(
        .NB_DATA(39)
    )
    u_stage_transition_mem_to_wb
    (
        .i_clock    (i_clock                        ),
        .i_reset    (i_reset || i_pc_reset          ),
        .i_valid    (i_enable_stages_transitions[0] ),
        .i_data     (signals_mem_to_wb              ),
        .o_data     (signals_mem_to_wb_d            )
    );

    // --------------------------------------------------
    // Write-back stage
    // --------------------------------------------------
    write_back u_write_back
    (
        .i_data_from_memory             (signals_mem_to_wb_d[33:2]  ),

        .i_jump_return_dest_register    (signals_mem_to_wb_d[38:34] ),
        .i_jump_return_dest             (signals_mem_to_wb_d[0]     ),

        .o_data_write_back              (data_from_write_back       ),
        .o_address_write_back           (address_from_write_back    )
    );

endmodule