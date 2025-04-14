`timescale 1ns / 1ps

module instruction_decode
#(
    parameter NB_DATA               = 32    ,
    parameter NB_WORD               = 16    ,
    parameter NB_REG_ADDRESS        = 5     ,
    parameter NB_JUMP_ADDRESS       = 26    ,
    parameter NB_OP_FIELD           = 6     ,
    parameter NB_FORWARDING_ENABLE  = 2
)
(
    //Intruccion
    input  wire [NB_DATA        -1 : 0] i_instruction                   , // DONE

    // Cortocircuito
    input  wire                         i_reg_write_id_ex               ,
    input  wire                         i_reg_write_ex_mem              ,
    input  wire                         i_reg_write_mem_wb              ,
    input  wire [NB_REG_ADDRESS -1 : 0] i_direc_rd_id_ex                ,
    input  wire [NB_REG_ADDRESS -1 : 0] i_direc_rd_ex_mem               ,
    input  wire [NB_REG_ADDRESS -1 : 0] i_direc_rd_mem_wb               ,
    input  wire [NB_DATA        -1 : 0] i_dato_de_id_ex                 ,
    input  wire [NB_DATA        -1 : 0] i_dato_de_ex_mem                ,
    input  wire [NB_DATA        -1 : 0] i_dato_de_mem_wb                ,

    //Al registro
    input  wire [NB_DATA        -1 : 0] i_write_reg_data                , // DONE
    input  wire [NB_REG_ADDRESS -1 : 0] i_write_reg_address             , // DONE

    // Debug
    output wire [NB_DATA        -1 : 0] o_debug_read_reg                , // DONE
    input  wire [NB_REG_ADDRESS -1 : 0] i_debug_read_reg_address        , // DONE

    // EQ/NEQ condition for jump or branch
    output wire [NB_DATA        -1 : 0] o_data_a_for_condition          , // DONE
    output wire [NB_DATA        -1 : 0] o_data_b_for_condition          , // DONE

    // Jump and branch addresses
    output wire [NB_DATA        -1 : 0] o_data_branch_address           , // DONE
    output wire [NB_JUMP_ADDRESS-1 : 0] o_data_jump_address             , // DONE

    // For return address
    input  wire [NB_DATA        -1 : 0] i_next_pc                       , // DONE

    //Data
    output wire [NB_DATA        -1 : 0] o_data_ra                       , // DONE
    output wire [NB_DATA        -1 : 0] o_data_rb                       , // DONE
    output wire [NB_DATA        -1 : 0] o_data_immediate_signed         , // DONE
    output wire [NB_REG_ADDRESS -1 : 0] o_reg_select_address_rs         , // DONE
    output wire [NB_REG_ADDRESS -1 : 0] o_reg_select_address_rt         , // DONE
    output wire [NB_REG_ADDRESS -1 : 0] o_reg_select_address_rd         , // DONE

    // Control signals
    output wire [NB_OP_FIELD    -1 : 0] o_control_unit_operation        , // DONE
    input  wire                         i_jump_or_branch                , // DONE

    input  wire                         i_reset                         ,
    input  wire                         i_clock
);

    wire  [NB_DATA              -1 : 0] data_immediate_signed;
    wire  [NB_DATA              -1 : 0] forwarding_reg_data_a;
    wire  [NB_DATA              -1 : 0] forwarding_reg_data_b;
    wire  [NB_DATA              -1 : 0] read_reg_data_a;
    wire  [NB_DATA              -1 : 0] read_reg_data_b;
    wire  [NB_FORWARDING_ENABLE -1 : 0] forward_select_bits_a;
    wire  [NB_FORWARDING_ENABLE -1 : 0] forward_select_bits_b;
    wire                                is_immediate_number_negative;

    // --------------------------------------------------
    // A/B forwarding data selection
    // --------------------------------------------------
    selector_mux
    #(
        .BITS_ENABLES       (NB_FORWARDING_ENABLE   ),
        .BUS_SIZE           (NB_DATA                )
    )
    u_select_forward_data_a
     (
        .i_en               (forward_select_bits_a                                                  ),
        .i_data             ({i_dato_de_id_ex, i_dato_de_mem_wb, i_dato_de_ex_mem, read_reg_data_a} ),
        .o_data             (forwarding_reg_data_a                                                  )
    );

    selector_mux
    #(
        .BITS_ENABLES       (NB_FORWARDING_ENABLE   ),
        .BUS_SIZE           (NB_DATA                )
    )
    u_select_forward_data_b
    (
        .i_en               (forward_select_bits_b                                                  ),
        .i_data             ({i_dato_de_id_ex, i_dato_de_mem_wb, i_dato_de_ex_mem, read_reg_data_b} ),
        .o_data             (forwarding_reg_data_b                                                  )
    );

    // --------------------------------------------------
    // Forwarding unit
    // --------------------------------------------------
    forwarding_unit u_forwarding_unit
    (
        .i_rs_if_id                 (i_instruction[25:21]           ),
        .i_rt_if_id                 (i_instruction[20:16]           ),
        .i_rd_id_ex                 (i_direc_rd_id_ex               ),
        .i_rd_ex_mem                (i_direc_rd_ex_mem              ),
        .i_rd_mem_wb                (i_direc_rd_mem_wb              ),
        .i_reg_wr_ex_mem            (i_reg_write_ex_mem             ),
        .i_reg_wr_id_ex             (i_reg_write_id_ex              ),
        .i_reg_wr_mem_wb            (i_reg_write_mem_wb             ),
        .o_forward_a                (forward_select_bits_a          ),
        .o_forward_b                (forward_select_bits_b          )
    );

    // --------------------------------------------------
    // Registers
    // --------------------------------------------------
    registers u_registers
    (
        .o_read_reg_data_a          (read_reg_data_a                ),
        .o_read_reg_data_b          (read_reg_data_b                ),
        .o_read_reg_data_debug      (o_debug_read_reg               ),

        .i_read_reg_address_a       (i_instruction[25:21]           ),
        .i_read_reg_address_b       (i_instruction[20:16]           ),
        .i_write_reg_data           (i_write_reg_data               ),
        .i_write_reg_address        (i_write_reg_address            ),
        .i_write_reg_enable         (i_reg_write_mem_wb             ),
        .i_read_reg_address_debug   (i_debug_read_reg_address       ),
        .i_reset                    (i_reset                        ),
        .i_clock                    (i_clock                        )
    );

    // --------------------------------------------------
    // Sign extension
    // --------------------------------------------------
    assign is_immediate_number_negative = i_instruction[NB_WORD-1] == 1;
    assign data_immediate_signed        = is_immediate_number_negative ? {16'b1111111111111111, i_instruction[15:0]} : {16'b0000000000000000, i_instruction[15:0]};

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_data_ra                = i_jump_or_branch ? i_next_pc : forwarding_reg_data_a;
    assign o_data_rb                = forwarding_reg_data_b;
    assign o_data_a_for_condition   = forwarding_reg_data_a;
    assign o_data_b_for_condition   = forwarding_reg_data_b;
    assign o_data_immediate_signed  = data_immediate_signed;

    assign o_reg_select_address_rd  = i_instruction[15:11];
    assign o_reg_select_address_rs  = i_instruction[25:21];
    assign o_reg_select_address_rt  = i_instruction[20:16];
    assign o_control_unit_operation = i_instruction[31:26];

    assign o_data_jump_address      = i_instruction[25:0];
    assign o_data_branch_address    = data_immediate_signed;

endmodule
