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
    input   [NB_DATA        -1 : 0] i_instruccion                   ,

    // Cortocircuito
    input                           i_reg_write_id_ex               ,
    input                           i_reg_write_ex_mem              ,
    input                           i_reg_write_mem_wb              ,
    input   [NB_REG_ADDRESS -1 : 0] i_direc_rd_id_ex                ,
    input   [NB_REG_ADDRESS -1 : 0] i_direc_rd_ex_mem               ,
    input   [NB_REG_ADDRESS -1 : 0] i_direc_rd_mem_wb               ,
    input   [NB_DATA        -1 : 0] i_dato_de_id_ex                 ,
    input   [NB_DATA        -1 : 0] i_dato_de_ex_mem                ,
    input   [NB_DATA        -1 : 0] i_dato_de_mem_wb                ,

    //Al registro
    input   [NB_DATA        -1 : 0] i_dato_de_escritura_en_reg      ,
    input   [NB_REG_ADDRESS -1 : 0] i_direc_de_escritura_en_reg     ,

    // Para Debug
    output  [NB_DATA        -1 : 0] o_dato_a_debug                  ,
    input   [NB_REG_ADDRESS -1 : 0] i_direc_de_lectura_de_debug     ,

    // Para comparar salto
    output  [NB_DATA        -1 : 0] o_dato_ra_para_condicion        ,
    output  [NB_DATA        -1 : 0] o_dato_rb_para_condicion        ,

    //Para Branch
    output  [NB_DATA        -1 : 0] o_dato_direc_branch             ,

    //Para Jump
    output  [NB_JUMP_ADDRESS-1 : 0] o_dato_direc_jump               ,

    // Para direccion de retorno
    input   [NB_DATA        -1 : 0] i_dato_nuevo_pc                 ,

    //Datos
    output  [NB_DATA        -1 : 0] o_dato_ra                       ,
    output  [NB_DATA        -1 : 0] o_dato_rb                       ,
    output  [NB_DATA        -1 : 0] o_dato_inmediato                ,
    
    output  [NB_REG_ADDRESS -1 : 0] o_direccion_rs                  ,
    output  [NB_REG_ADDRESS -1 : 0] o_direccion_rt                  ,
    output  [NB_REG_ADDRESS -1 : 0] o_direccion_rd                  ,

    // A control
    output  [NB_OP_FIELD    -1 : 0] o_campo_op                      ,

    // Flags de control
    input                           i_jump_o_branch                 ,

    input                           i_reset                         ,
    input                           i_clock
);

    wire  [NB_DATA              -1 : 0] salida_de_forwarding_dato_a;
    wire  [NB_DATA              -1 : 0] salida_del_ra              ;
    wire  [NB_DATA              -1 : 0] salida_del_rb              ;
    wire  [NB_FORWARDING_ENABLE -1 : 0] bits_de_forward_a          ;
    wire  [NB_FORWARDING_ENABLE -1 : 0] bits_de_forward_b          ;

    mux
    #(
        .BITS_ENABLES       (1                      ),
        .BUS_SIZE           (NB_DATA                )
    )
    u_mux_de_dato_o_pc
    (
        .i_en               (i_jump_o_branch                                                        ),
        .i_data             ({i_dato_nuevo_pc,salida_de_forwarding_dato_a}                          ),
        .o_data             (o_dato_ra                                                              )
    );

     mux
     #(
        .BITS_ENABLES       (NB_FORWARDING_ENABLE   ),
        .BUS_SIZE           (NB_DATA                )
    )
    u_mux_de_forward_para_dato_a
     (
        .i_en               (bits_de_forward_a                                                      ),
        .i_data             ({i_dato_de_id_ex,i_dato_de_mem_wb ,i_dato_de_ex_mem,salida_del_ra }    ),
        .o_data             (salida_de_forwarding_dato_a                                            )
    );

    mux
    #(
        .BITS_ENABLES       (NB_FORWARDING_ENABLE   ),
        .BUS_SIZE           (NB_DATA                )
    )
    u_mux_de_forward_para_dato_b
    (
        .i_en               (bits_de_forward_b                                                      ),
        .i_data             ({i_dato_de_id_ex,i_dato_de_mem_wb,i_dato_de_ex_mem,salida_del_rb }     ),
        .o_data             (o_dato_rb                                                              )
    );

    // --------------------------------------------------
    // Forwarding unit
    // --------------------------------------------------
    forwarding_unit u_forwarding_unit
    (
        .i_rs_if_id             (i_instruccion[25:21]           ),
        .i_rt_if_id             (i_instruccion[20:16]           ),
        .i_rd_id_ex             (i_direc_rd_id_ex               ),
        .i_rd_ex_mem            (i_direc_rd_ex_mem              ),
        .i_rd_mem_wb            (i_direc_rd_mem_wb              ),
        .i_reg_wr_ex_mem        (i_reg_write_ex_mem             ),
        .i_reg_wr_id_ex         (i_reg_write_id_ex              ),
        .i_reg_wr_mem_wb        (i_reg_write_mem_wb             ),
        .o_forward_a            (bits_de_forward_a              ),
        .o_forward_b            (bits_de_forward_b              )
    );

    // --------------------------------------------------
    // Registers
    // --------------------------------------------------
    registers u_registers
    (
        .o_read_reg_data_a          (salida_del_ra                  ),
        .o_read_reg_data_b          (salida_del_rb                  ),
        .o_read_reg_data_debug      (o_dato_a_debug                 ),

        .i_read_reg_address_a       (i_instruccion[25:21]           ),
        .i_read_reg_address_b       (i_instruccion[20:16]           ),
        .i_write_reg_data           (i_dato_de_escritura_en_reg     ),
        .i_write_reg_address        (i_direc_de_escritura_en_reg    ),
        .i_write_reg_enable         (i_reg_write_mem_wb             ),
        .i_read_reg_address_debug   (i_direc_de_lectura_de_debug    ),
        .i_reset                    (i_reset                        ),
        .i_clock                    (i_clock                        )
    );

    // --------------------------------------------------
    // Sign extension
    // --------------------------------------------------
    // FIXME este bloque vuela
    // sign_extender u_sign_extender
    // (
    //     .data_in                (i_instruccion[15:0]            ),
    //     .data_out               (o_dato_inmediato               )
    // );
    wire is_number_negative;
    assign is_number_negative = i_instruccion[NB_WORD-1] == 1;
    assign o_dato_inmediato   = is_number_negative ? {16'b1111111111111111, i_instruccion[15:0]} : {16'b0000000000000000, i_instruccion[15:0]};

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign  o_campo_op               = i_instruccion[31:26]       ;
    assign  o_dato_direc_branch      = o_dato_inmediato           ; // FIXME esto wtf ?? esta duplicada la salida
    assign  o_dato_direc_jump        = i_instruccion[25:0]        ;
    assign  o_dato_ra_para_condicion = salida_de_forwarding_dato_a;
    assign  o_dato_rb_para_condicion = o_dato_rb                  ;
    assign  o_direccion_rd           = i_instruccion[15:11]       ;
    assign  o_direccion_rs           = i_instruccion[25:21]       ;
    assign  o_direccion_rt           = i_instruccion[20:16]       ;

endmodule