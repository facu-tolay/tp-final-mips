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
    parameter NB_SIGNALS            = 18
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

    //  17      16      15        14     13      12   11    10    9       8       7       6        5        4        3         2          1        0
    //RegDst MemToReg MemRead   Branch MemWrite Ope2 Ope1 Ope0 ALUSrc RegWrite ShiftSrc JmpSrc JReturnDst EQorNE DataMask1 DataMask0 IsUnsigned JmpOrBrch
    localparam  REG_DST         =   17;
    localparam  MEM_TO_REG      =   16;
    localparam  MEM_READ        =   15;
    localparam  BRANCH          =   14;
    localparam  MEM_WRITE       =   13;
    localparam  OP2             =   12;
    localparam  OP1             =   11;
    localparam  OP0             =   10;
    localparam  ALU_SRC         =    9;
    localparam  REG_WRITE       =    8;
    localparam  SHIFT_SRC       =    7;
    localparam  JMP_SRC         =    6;
    localparam  J_RETURN_DST    =    5;
    localparam  EQ_OR_NEQ       =    4;
    localparam  DATA_MASK_1     =    3;
    localparam  DATA_MASK_0     =    2;
    localparam  IS_UNSIGNED     =    1;
    localparam  JMP_OR_BRCH     =    0;

    /*====================================== Instruction fetch  =============================*/
    wire    [NB_DATA -1:0]              instruction;
    wire    [NB_DATA -1:0]              pc_value;
    wire                                mux_eq_neq;
    /*====================================== Latch IF/ID        =============================*/
    wire    [NB_DATA  * 2 - 1:0]        de_if_a_id;
    /*====================================== MUXES IF/ID        =============================*/
    wire    [NB_DATA -1:0]              next_pc;
    wire    [NB_DATA -1:0]              mux_dir;
    wire    [NB_DATA -1:0]              mux_pc_immediate;
    /*====================================== Sumador IMMEDIATE  =============================*/
    wire    [NB_DATA -1:0]              immediate_suma_result;
    /*====================================== Sumador PC         =============================*/
    wire    [NB_DATA -1:0]              pc_suma_result;
    /*====================================== Control Unit       =============================*/
    wire    [NB_SIGNALS-1:0]            control_signals;
    /*====================================== Instruction Decode =============================*/
    wire    [NB_DATA -1:0]              o_dato_ra_para_condicion;
    wire    [NB_DATA -1:0]              o_dato_rb_para_condicion;
    wire    [NB_DATA -1:0]              o_dato_direc_branch;
    wire    [NB_JUMP_ADDRESS-1:0]       o_dato_direc_jump;
    wire    [NB_DATA -1:0]              o_dato_ra;
    wire    [NB_DATA -1:0]              o_dato_rb;
    wire    [NB_DATA -1:0]              o_dato_inmediato;
    wire    [NB_REG_ADDRESS-1:0]        o_direccion_rs;
    wire    [NB_REG_ADDRESS-1:0]        o_direccion_rd;
    wire    [NB_REG_ADDRESS-1:0]        o_direccion_rt;
    wire    [NB_OP_FIELD-1:0]           o_campo_op;
    /*====================================== Latch ID/EX        =============================*/
    wire    [120-1:0]                   de_id_a_ex;
    /*====================================== Excecution         =============================*/
    wire    [NB_DATA -1:0]              o_mem_data;
    wire    [NB_DATA -1:0]              alu_result;
    wire    [NB_REG_ADDRESS-1:0]        o_reg_address;
    /*====================================== Latch EX/MEM       =============================*/
    wire    [76-1:0]                    de_ex_a_mem;
    /*====================================== Memory Access      =============================*/
    wire    [NB_DATA -1:0]              o_data_salida_de_memoria;
    /*====================================== Latch MEM/WB       =============================*/
    wire    [39-1:0]                    de_mem_a_wb;
    /*====================================== Write Back         =============================*/
    wire    [NB_DATA -1:0]              dato_salido_wb;
    wire    [NB_REG_ADDRESS-1:0]        direccion_de_wb;


    // --------------------------------------------------
    // Instruction Fetch stage
    // --------------------------------------------------
    instruction_fetch u_instruction_fetch
    (
        .o_instruction              (instruction                    ),
        .o_is_end                   (o_is_program_end               ),
        .o_pc_value                 (pc_value                       ),

        .i_pc_reset                 (i_pc_reset                     ),
        .i_stall                    (i_enable_stages_transitions[4] && stall_latch ),
        .i_next_pc                  (next_pc                        ),
        .i_load_program_write_enable(i_load_program_write_enable    ),
        .i_load_program_byte        (i_load_program_byte            ),
        .i_reset                    (i_reset || i_delete_program    ),
        .i_clock                    (i_clock                        )
    );

    assign o_debug_read_pc = pc_value;

    // --------------------------------------------------
    // Next PC adder
    // --------------------------------------------------
    assign pc_suma_result = pc_value + 32'h4;

    // --------------------------------------------------
    // Stage transition registers IF/ID
    // --------------------------------------------------
    // FIXME ver si agregar un nombre tipo stage_trstn_if_id
    wire [NB_DATA       -1 : 0] pc_plus_4_d;
    wire [NB_DATA       -1 : 0] instruction_d;
    wire [NB_OP_FIELD   -1 : 0] instruction_function_d;

    assign de_if_a_id             = {instruction_d, pc_plus_4_d};
    assign instruction_function_d = instruction_d[NB_OP_FIELD-1 : 0];

    stage_transition
    #(
        .NB_DATA(NB_DATA)
    )
    if_id_latch_pc_mas_cuatro
    (
        .o_data     (pc_plus_4_d                    ),

        .i_data     (pc_suma_result                 ),
        .i_valid    (i_enable_stages_transitions[3] && stall_latch),
        .i_reset    (i_reset || i_pc_reset          ),
        .i_clock    (i_clock                        )
    );

    stage_transition
    #(
        .NB_DATA(NB_DATA)
    )
    if_id_latch_inst
    (
        .i_clock    (i_clock                                                ),
        .i_reset    (i_reset || (i_enable_stages_transitions[3] && if_flush) || i_pc_reset ),
        .i_valid    (i_enable_stages_transitions[3] && stall_latch                         ),
        .i_data     (instruction                                            ),
        .o_data     (instruction_d                                          )
    );

    // --------------------------------------------------
    // Stage transition muxes IF/ID
    // --------------------------------------------------
    assign i_eq_neq                = o_dato_ra_para_condicion != o_dato_rb_para_condicion;
    assign mux_eq_neq              = control_signals[EQ_OR_NEQ] ? i_eq_neq : ~i_eq_neq;

    assign mux_dir                 = control_signals[JMP_SRC] ? {6'b0,o_dato_direc_jump} << 2 : o_dato_ra_para_condicion;

    assign immediate_suma_result   = pc_plus_4_d + $signed(o_dato_direc_branch << 2);
    assign enable_mux_pc_immediate = mux_eq_neq && control_signals[BRANCH];
    assign mux_pc_immediate        = enable_mux_pc_immediate ? immediate_suma_result : pc_suma_result;

    assign next_pc                 = control_signals[JMP_OR_BRCH] ? mux_dir : mux_pc_immediate;

    // --------------------------------------------------
    // Hazard unit
    // --------------------------------------------------
    hazard_unit u_hazard_unit
    (
        .i_jump_branch      (control_signals[JMP_OR_BRCH]),
        .i_branch           (enable_mux_pc_immediate     ),
        .i_mem_read_id_ex   (de_id_a_ex[4]               ), // FIXME pasar a una expresion wire y assign
        .i_rs_if_id         (o_direccion_rs              ),
        .i_rt_if_id         (o_direccion_rt              ),
        .i_rt_id_ex         (de_id_a_ex[114 : 110]       ), // FIXME pasar a una expresion wire y assign
        .o_if_flush         (if_flush                    ),
        .o_risk_detected    (stall_ctl                   ),
        .o_no_risk_detected (stall_latch                 )
    );

    // --------------------------------------------------
    // Control unit
    // --------------------------------------------------
    control_unit u_control_unit
    (
        .i_function         (instruction_function_d ), // FIXME pasar a una expresion wire y assign
        .i_operation        (o_campo_op             ),
        .i_enable_control   (stall_ctl              ),
        .o_control          (control_signals        )
    );

    // --------------------------------------------------
    // Instruction decode stage
    // --------------------------------------------------
    instruction_decode u_instruction_decode
    (
        // Data
        .o_data_ra                      (o_dato_ra                      ),
        .o_data_rb                      (o_dato_rb                      ),
        .o_data_immediate_signed        (o_dato_inmediato               ),
        .o_reg_select_address_rs        (o_direccion_rs                 ),
        .o_reg_select_address_rt        (o_direccion_rt                 ),
        .o_reg_select_address_rd        (o_direccion_rd                 ),

        // EQ/NEQ condition for jump or branch
        .o_data_a_for_condition         (o_dato_ra_para_condicion       ),
        .o_data_b_for_condition         (o_dato_rb_para_condicion       ),

        // Jump and branch addresses
        .o_data_branch_address          (o_dato_direc_branch            ),
        .o_data_jump_address            (o_dato_direc_jump              ),

        // Intruccion
        .i_instruction                  (instruction_d                  ), // FIXME pasar a una expresion wire y assign

        // Forwarding
        .i_reg_enable_write_id_ex       (de_id_a_ex[2]                  ), // FIXME pasar a una expresion wire y assign
        .i_reg_enable_write_ex_mem      (de_ex_a_mem[2]                 ), // FIXME pasar a una expresion wire y assign
        .i_reg_enable_write_mem_wb      (de_mem_a_wb[1]                 ), // FIXME pasar a una expresion wire y assign
        .i_reg_address_rd_id_ex         (o_reg_address                  ),
        .i_reg_address_rd_ex_mem        (de_ex_a_mem[75:71]             ), // FIXME pasar a una expresion wire y assign
        .i_reg_address_rd_mem_wb        (direccion_de_wb                ),
        .i_data_from_execution_stage    (alu_result                     ),
        .i_data_from_memory_access      (o_data_salida_de_memoria       ),
        .i_data_from_write_back         (dato_salido_wb                 ),

        // For register bank
        .i_write_reg_data               (dato_salido_wb                 ),
        .i_write_reg_address            (direccion_de_wb                ),

        // For return address
        .i_next_pc                      (pc_plus_4_d                    ),

        // Control signals
        .o_control_unit_operation       (o_campo_op                     ),
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
    stage_transition
    #(
        .NB_DATA(120)
    )
    id_ex_latch
    (
        .i_clock        (i_clock                        ),
        .i_reset        (i_reset || i_pc_reset          ),
        .i_valid        (i_enable_stages_transitions[2] ),
        .i_data         ({o_direccion_rd, o_direccion_rt,o_dato_inmediato, o_dato_rb,   // FIXME pasar a una expresion wire y assign
                          o_dato_ra, control_signals[REG_DST], control_signals[ALU_SRC], control_signals[OP2:OP0],
                          control_signals[SHIFT_SRC], control_signals[DATA_MASK_1:DATA_MASK_0],
                          control_signals[MEM_WRITE], control_signals[MEM_READ]  , control_signals[IS_UNSIGNED],
                          control_signals[REG_WRITE], control_signals[MEM_TO_REG], control_signals[J_RETURN_DST]}),
        .o_data         (de_id_a_ex                     )
    );

    // --------------------------------------------------
    // Execution stage
    // --------------------------------------------------
    execution u_execution_stage
    (
        .i_shift_source         (de_id_a_ex[8]          ), // FIXME pasar a una expresion wire y assign
        .i_register_destination (de_id_a_ex[13]         ), // FIXME pasar a una expresion wire y assign
        .i_alu_source           (de_id_a_ex[12]         ), // FIXME pasar a una expresion wire y assign
        .i_alu_operation        (de_id_a_ex[11:9]       ), // FIXME pasar a una expresion wire y assign
        .i_ra_data              (de_id_a_ex[45:14]      ), // FIXME pasar a una expresion wire y assign
        .i_rb_data              (de_id_a_ex[77:46]      ), // FIXME pasar a una expresion wire y assign
        .i_sign_extender_data   (de_id_a_ex[109:78]     ), // FIXME pasar a una expresion wire y assign
        .i_rt_address           (de_id_a_ex[114 : 110]  ), // FIXME pasar a una expresion wire y assign
        .i_rd_address           (de_id_a_ex[119 : 115]  ), // FIXME pasar a una expresion wire y assign
        .o_register_address     (o_reg_address          ),
        .o_memory_data          (o_mem_data             ),
        .o_alu_result           (alu_result             )
    );

    // --------------------------------------------------
    // Stage transition register for EX/MEM
    // --------------------------------------------------
    stage_transition
    #(
        .NB_DATA(76)
    )
    ex_mem_latch
    (
        .i_clock    (i_clock                        ),
        .i_reset    (i_reset || i_pc_reset          ),
        .i_valid    (i_enable_stages_transitions[1] ),
        .i_data     ({o_reg_address, o_mem_data, alu_result, de_id_a_ex[7:5], de_id_a_ex[3:0]}), // FIXME pasar a una expresion wire y assign
        .o_data     (de_ex_a_mem                    )
    );

    // --------------------------------------------------
    // Memory access stage
    // --------------------------------------------------
    memory_access u_memory_access
    (
        .i_data_write               (de_ex_a_mem[70:39]       ), // FIXME pasar a una expresion wire y assign
        .i_data_mask                (de_ex_a_mem[6:5]         ), // FIXME pasar a una expresion wire y assign
        .i_memory_to_register       (de_ex_a_mem[1]           ), // FIXME pasar a una expresion wire y assign
        .i_is_unsigned              (de_ex_a_mem[3]           ), // FIXME pasar a una expresion wire y assign
        .i_write_enable             (de_ex_a_mem[4]           ), // FIXME pasar a una expresion wire y assign

        .i_memory_address           (de_ex_a_mem[38:7]        ), // FIXME pasar a una expresion wire y assign
        .o_data                     (o_data_salida_de_memoria ),

        .i_debug_read_mem_address   (i_debug_read_mem_address ),
        .o_debug_read_mem           (o_debug_read_mem         ),

        .i_reset                    (i_reset|| i_pc_reset     ),
        .i_clock                    (i_clock                  )
    );

    // --------------------------------------------------
    // Stage transition register for MEM/WB
    // --------------------------------------------------
    stage_transition
    #(
        .NB_DATA(39)
    )
    mem_wb_latch
    (
        .i_clock    (i_clock                        ),
        .i_reset    (i_reset || i_pc_reset          ),
        .i_valid    (i_enable_stages_transitions[0] ),
        .i_data     ({de_ex_a_mem[75:71], o_data_salida_de_memoria,de_ex_a_mem[2] ,de_ex_a_mem[0]}), // FIXME pasar a una expresion wire y assign
        .o_data     (de_mem_a_wb                    )
    );

    // --------------------------------------------------
    // Write-back stage
    // --------------------------------------------------
    write_back u_write_back
    (
        .i_data_from_memory             (de_mem_a_wb[33:2]  ), // FIXME pasar a una expresion wire y assign

        .i_jump_return_dest_register    (de_mem_a_wb[38:34] ), // FIXME pasar a una expresion wire y assign
        .i_jump_return_dest             (de_mem_a_wb[0]     ), // FIXME pasar a una expresion wire y assign

        .o_data_write_back              (dato_salido_wb     ),
        .o_address_write_back           (direccion_de_wb    )
    );
endmodule