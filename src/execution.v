`timescale 1ns / 1ps

module execution
#(
    parameter NB_DATA           = 32,
    parameter NB_REG_ADDRESS    = 5 ,
    parameter NB_OP_FIELD       = 6 ,
    parameter NB_ALU_OP_FIELD   = 3
)
(
    input                           i_shift_src         ,
    input                           i_reg_dst           ,
    input                           i_alu_src           ,
    input   [NB_ALU_OP_FIELD-1 : 0] i_alu_op            ,
    input   [NB_DATA        -1 : 0] i_ra_data           ,
    input   [NB_DATA        -1 : 0] i_rb_data           ,
    input   [NB_DATA        -1 : 0] i_sign_extender_data,
    input   [NB_REG_ADDRESS -1 : 0] i_rt_address        ,
    input   [NB_REG_ADDRESS -1 : 0] i_rd_address        ,
    output  [NB_REG_ADDRESS -1 : 0] o_reg_address       ,
    output  [NB_DATA        -1 : 0] o_mem_data          ,
    output  [NB_DATA        -1 : 0] o_alu_data
);

    wire [NB_OP_FIELD -1 : 0] o_alu_func      ;
    wire [NB_DATA     -1 : 0] o_mux_alu_data_a;
    wire [NB_DATA     -1 : 0] o_mux_alu_data_b;

    // --------------------------------------------------
    // Destination register selection
    // --------------------------------------------------
    mux
    #(
        .BITS_ENABLES   (1              ),
        .BUS_SIZE       (NB_REG_ADDRESS )
    )
    mux_reg
    (
        .i_en           (i_reg_dst                                          ),
        .i_data         ({i_rt_address, i_rd_address}                       ),
        .o_data         (o_reg_address                                      )
    );

    // --------------------------------------------------
    // A/B data selection
    // --------------------------------------------------
    mux
    #(
        .BITS_ENABLES   (1              ),
        .BUS_SIZE       (NB_DATA        )
    )
    mux_alu
    (
        .i_en           (i_alu_src                                          ),
        .i_data         ({i_sign_extender_data, i_rb_data}                  ),
        .o_data         (o_mux_alu_data_b                                   )
    );

    mux
    #(
        .BITS_ENABLES   (1              ),
        .BUS_SIZE       (NB_DATA        )
    )
    mux_shift
    (
        .i_en           (i_shift_src                                        ),
        .i_data         ({{27'b0, i_sign_extender_data[10 : 6]}, i_ra_data} ),
        .o_data         (o_mux_alu_data_a                                   )
    );

    // --------------------------------------------------
    // ALU control block
    // --------------------------------------------------
    alu_control u_alu_control
    (
        .i_alu_op       (i_alu_op                               ),
        .i_func         (i_sign_extender_data[NB_OP_FIELD-1 : 0]),
        .o_alu_func     (o_alu_func                             )
    );

    // --------------------------------------------------
    // ALU core block
    // --------------------------------------------------
    alu u_alu
    (
        .i_data_a       (o_mux_alu_data_a       ),
        .i_data_b       (o_mux_alu_data_b       ),
        .i_func         (o_alu_func             ),
        .o_out          (o_alu_data             ),
        .o_zero_bit     (zero_bit               )
    );

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_mem_data = i_rb_data;

endmodule