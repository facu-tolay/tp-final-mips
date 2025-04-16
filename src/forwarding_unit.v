`timescale 1ns / 1ps

module forwarding_unit
#(
    parameter NB_REG_ADDRESS        = 5,
    parameter NB_FORWARDING_ENABLE  = 2
)
(
    input  wire [NB_REG_ADDRESS         -1 : 0] i_rs_if_id,
    input  wire [NB_REG_ADDRESS         -1 : 0] i_rt_if_id,
    input  wire [NB_REG_ADDRESS         -1 : 0] i_rd_id_ex,
    input  wire [NB_REG_ADDRESS         -1 : 0] i_rd_ex_mem,
    input  wire [NB_REG_ADDRESS         -1 : 0] i_rd_mem_wb,
    input  wire                                 i_reg_wr_ex_mem,
    input  wire                                 i_reg_wr_id_ex,
    input  wire                                 i_reg_wr_mem_wb,
    output wire [NB_FORWARDING_ENABLE   -1 : 0] o_forward_a,
    output wire [NB_FORWARDING_ENABLE   -1 : 0] o_forward_b
);

    // --------------------------------------------------
    // Output logic for forwarding A
    // --------------------------------------------------
    assign o_forward_a = (i_reg_wr_id_ex  && (i_rd_id_ex  != 0) && (i_rd_id_ex  == i_rs_if_id)) ? 2'b11 : // Lo saca de la ALU (etapa de id/ex)
                         (i_reg_wr_ex_mem && (i_rd_ex_mem != 0) && (i_rd_ex_mem == i_rs_if_id)) ? 2'b01 : // Lo saca de la salida de la ALU (etapa ex/mem)
                         (i_reg_wr_mem_wb && (i_rd_mem_wb != 0) && (i_rd_mem_wb == i_rs_if_id)) ? 2'b10 : // Lo saca del WB
                         2'b00; // Lo saca del registro

    // --------------------------------------------------
    // Output logic for forwarding B
    // --------------------------------------------------
    assign o_forward_b = (i_reg_wr_id_ex  && (i_rd_id_ex  != 0) && (i_rd_id_ex  == i_rt_if_id)) ? 2'b11 : // Lo saca de la ALU (etapa id/ex)
                         (i_reg_wr_ex_mem && (i_rd_ex_mem != 0) && (i_rd_ex_mem == i_rt_if_id)) ? 2'b01 : // Lo saca de la ALU /etapa ex/mem
                         (i_reg_wr_mem_wb && (i_rd_mem_wb != 0) && (i_rd_mem_wb == i_rt_if_id)) ? 2'b10 : // Lo saca del WB
                         2'b00; // Lo saca del registro

endmodule