`timescale 1ns / 1ps

module hazard_unit
#(
    parameter NB_REG_ADDRESS = 5
)
(
    output wire                         o_risk_detected     ,
    output wire                         o_no_risk_detected  ,
    output wire                         o_if_flush          ,

    input  wire [NB_REG_ADDRESS -1 : 0] i_rs_if_id          ,
    input  wire [NB_REG_ADDRESS -1 : 0] i_rt_if_id          ,
    input  wire [NB_REG_ADDRESS -1 : 0] i_rt_id_ex          ,
    input  wire                         i_jump_branch       ,
    input  wire                         i_branch            ,
    input  wire                         i_mem_read_id_ex
);

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_risk_detected      = ((i_mem_read_id_ex) && (i_rt_id_ex == i_rs_if_id || i_rt_id_ex == i_rt_if_id)) ? 1'b1 : 1'b0;
    assign o_no_risk_detected   = ~o_risk_detected;
    assign o_if_flush           = i_jump_branch || i_branch;

endmodule