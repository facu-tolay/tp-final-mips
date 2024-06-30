module hazard_detection_unit
#(
    NB_REGISTER_SELECT      = 5
)
(
    output wire                             o_stall             ,

    input  wire                             i_mem_read_index    ,
    input  wire [NB_REGISTER_SELECT -1 : 0] i_rt_index          ,
    input  wire [NB_REGISTER_SELECT -1 : 0] i_rt_ifid           ,
    input  wire [NB_REGISTER_SELECT -1 : 0] i_rs_ifid
);

    assign o_stall = i_mem_read_index && (i_rt_index == i_rs_ifid || i_rt_index == i_rt_ifid);

endmodule
