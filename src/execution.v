`timescale 1ns / 1ps

module execution
#(
    parameter NB_DATA           = 32,
    parameter NB_REG_ADDRESS    = 5,
    parameter NB_OP_FIELD       = 6,
    parameter NB_ALU_OP_FIELD   = 3
)
(
    input  wire                             i_shift_source          ,
    input  wire                             i_register_destination  ,
    input  wire                             i_alu_source            ,
    input  wire [NB_ALU_OP_FIELD    -1 : 0] i_alu_operation         ,
    input  wire [NB_DATA            -1 : 0] i_ra_data               ,
    input  wire [NB_DATA            -1 : 0] i_rb_data               ,
    input  wire [NB_DATA            -1 : 0] i_sign_extender_data    ,
    input  wire [NB_REG_ADDRESS     -1 : 0] i_rt_address            ,
    input  wire [NB_REG_ADDRESS     -1 : 0] i_rd_address            ,
    output wire [NB_REG_ADDRESS     -1 : 0] o_register_address      ,
    output wire [NB_DATA            -1 : 0] o_memory_data           ,
    output wire [NB_DATA            -1 : 0] o_alu_result
);

    wire [NB_OP_FIELD -1 : 0] alu_opcode;
    wire [NB_DATA     -1 : 0] alu_data_select_a;
    wire [NB_DATA     -1 : 0] alu_data_select_b;

    // --------------------------------------------------
    // Destination register selection
    // --------------------------------------------------
    assign o_register_address = i_register_destination ? i_rt_address : i_rd_address; // FIXME probar

    // --------------------------------------------------
    // A/B data selection
    // --------------------------------------------------
    assign alu_data_select_a = i_shift_source ? {27'b0, i_sign_extender_data[10 : 6]} : i_ra_data; // FIXME probar
    assign alu_data_select_b = i_alu_source ? i_sign_extender_data : i_rb_data; // FIXME probar

    // --------------------------------------------------
    // ALU control block
    // --------------------------------------------------
    alu_control u_alu_control
    (
        .i_alu_operation    (i_alu_operation                            ),
        .i_alu_function     (i_sign_extender_data[NB_OP_FIELD-1 : 0]    ),
        .o_alu_opcode       (alu_opcode                                 )
    );

    // --------------------------------------------------
    // ALU core block
    // --------------------------------------------------
    alu u_alu
    (
        .i_data_a           (alu_data_select_a                          ),
        .i_data_b           (alu_data_select_b                          ),
        .i_opcode           (alu_opcode                                 ),
        .o_result           (o_alu_result                               ),
        .o_zero_bit         (                                           )
    );

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_memory_data = i_rb_data;

endmodule