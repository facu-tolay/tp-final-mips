`timescale 1ns / 1ps


module top
#(
    parameter   NB_DATA   = 6
)
(
    input wire                      i_switch        ,
    input wire                      i_clock         ,
    input wire                      i_reset         ,

    output wire [NB_DATA - 1 : 0]   o_data
);

    switch_debounce
    #(
    )
    u_switch_debounce
    (
        .o_signal           (o_data[5] ),

        .i_switch           (i_switch  ),
        .i_clock            (i_clock   ),
        .i_reset            (i_reset   )
    );

    fetch_stage
    #(
    )
    u_fetch_stage
    (
        .o_pc_next          (           ),
        .o_halt             (           ),
        .o_instruction      (           ),
        .o_rs               (o_data[4:0]),
        .o_rt               (           ),

        .i_pc_salto         (           ),
        .i_halt             (1'b0       ),
        .i_stall            (1'b0       ),
        .i_pc_src           (1'b0       ),
        .i_valid            (1'b1       ),
        .i_clock            (i_clock    ),
        .i_reset            (i_reset    )
    );

    // --------------------------------------------------
    // Output block
    // --------------------------------------------------
    // assign o_data           = data_result           ;

endmodule