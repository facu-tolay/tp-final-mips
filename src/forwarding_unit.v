`timescale 1ns / 1ps

module forwarding_unit
#(
    parameter NB_REG_ADDRESS        = 5,
    parameter NB_FORWARDING_ENABLE  = 2
)
(
    input   [NB_REG_ADDRESS         -1 : 0] i_rs_if_id     ,
    input   [NB_REG_ADDRESS         -1 : 0] i_rt_if_id     ,
    input   [NB_REG_ADDRESS         -1 : 0] i_rd_id_ex     ,
    input   [NB_REG_ADDRESS         -1 : 0] i_rd_ex_mem    ,
    input   [NB_REG_ADDRESS         -1 : 0] i_rd_mem_wb    ,
    input                                   i_reg_wr_ex_mem,
    input                                   i_reg_wr_id_ex ,
    input                                   i_reg_wr_mem_wb,
    output  [NB_FORWARDING_ENABLE   -1 : 0] o_forward_a    ,
    output  [NB_FORWARDING_ENABLE   -1 : 0] o_forward_b
);

    // --------------------------------------------------
    // Output logic for forwarding A
    // --------------------------------------------------
    // FIXME hacer un case
    assign o_forward_a = (i_reg_wr_id_ex && (i_rd_id_ex != 0) && (i_rd_id_ex == i_rs_if_id))
                          ? 2'b11 //Lo saca de la ALU (etapa de id/ex)
                          : (i_reg_wr_ex_mem && (i_rd_ex_mem != 0) && (i_rd_ex_mem == i_rs_if_id))
                          ? 2'b01 //Lo saca de la salida de la ALU (etapa ex/mem)
                          : (i_reg_wr_mem_wb && (i_rd_mem_wb != 0) && (i_rd_mem_wb == i_rs_if_id))
                          ? 2'b10 //Lo saca del WB
                          : 2'b00; //Lo saca del registro

    // --------------------------------------------------
    // Output logic for forwarding B
    // --------------------------------------------------
    // FIXME hacer un case
    assign o_forward_b = (i_reg_wr_id_ex && (i_rd_id_ex != 0) && (i_rd_id_ex == i_rt_if_id))
                          ? 2'b11 //Lo saca de la ALU (etapa id/ex)
                          : (i_reg_wr_ex_mem && (i_rd_ex_mem != 0) && (i_rd_ex_mem == i_rt_if_id))
                          ? 2'b01 //Lo saca de la ALU /etapa ex/mem
                          : (i_reg_wr_mem_wb && (i_rd_mem_wb != 0) && (i_rd_mem_wb == i_rt_if_id))
                          ? 2'b10 //Lo saca del WB
                          : 2'b00; //Lo saca del registro

endmodule