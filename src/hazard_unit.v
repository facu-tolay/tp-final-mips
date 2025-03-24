`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2022 10:52:48
// Design Name: 
// Module Name: hazard_unit
// <-----------------------------------------------
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hazard_unit #(
    parameter REG_SIZE = 5
)
(
    input                       i_jmp_brch,
    input                       i_brch,
    input                       i_mem_read_id_ex,
    input   [REG_SIZE-1 : 0]    i_rs_if_id,
    input   [REG_SIZE-1 : 0]    i_rt_if_id,
    input   [REG_SIZE-1 : 0]    i_rt_id_ex,
    output                      o_latch_en,
    output                      o_if_flush,    
    output                      o_is_risky
);

assign  o_is_risky = //(i_jmp_brch    ||  i_brch)  ||
                                      ((i_mem_read_id_ex) 
                                    &&  (i_rt_id_ex == i_rs_if_id 
                                    ||  i_rt_id_ex == i_rt_if_id)) 
                                ? 1'b1 
                                : 1'b0;
assign  o_if_flush = (i_jmp_brch    ||  i_brch);
assign  o_latch_en = ~o_is_risky;

endmodule