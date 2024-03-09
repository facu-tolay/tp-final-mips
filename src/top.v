`timescale 1ns / 1ps


module top
#(
    parameter   NB_DATA   = 5
)
(
    input wire                      i_clock         ,
    input wire                      i_reset         ,

    output wire [NB_DATA   - 1 : 0] o_data
);

    fetch_stage
    #(
    )
    u_fetch_stage
    (
        .i_pc_salto         (           ),
        .i_halt             (           ),
        .i_stall            (           ),
        .i_pc_src           (           ),
        .i_step             (           ),
        .i_valid            (           ),
        .i_reset            (i_reset    ),
        .i_clock            (i_clock    ),

        .o_pc_4             (           ),
        .o_halt             (           ),
        .o_instruction      (           ),
        .o_rs               (o_data     ),
        .o_rt               (           )
    );

    // --------------------------------------------------
    // Output block
    // --------------------------------------------------
    // assign o_data           = data_result           ;

endmodule