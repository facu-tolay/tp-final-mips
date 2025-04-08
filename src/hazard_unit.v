`timescale 1ns / 1ps

module hazard_unit
#(
    parameter NB_REG_ADDRESS = 5
)
(
    output                          o_risk_detected     ,
    output                          o_latch_en          ,
    output                          o_if_flush          ,

    input   [NB_REG_ADDRESS -1 : 0] i_rs_if_id          ,
    input   [NB_REG_ADDRESS -1 : 0] i_rt_if_id          ,
    input   [NB_REG_ADDRESS -1 : 0] i_rt_id_ex          ,
    input                           i_jmp_brch          ,
    input                           i_brch              ,
    input                           i_mem_read_id_ex
);

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_risk_detected = ((i_mem_read_id_ex) && (i_rt_id_ex == i_rs_if_id || i_rt_id_ex == i_rt_if_id)) ? 1'b1 : 1'b0;
    assign o_if_flush      = i_jmp_brch || i_brch                                                                        ;
    assign o_latch_en      = ~o_risk_detected                                                                            ;

endmodule