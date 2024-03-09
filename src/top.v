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
        .o_pc_4             (           ),
        .o_halt             (           ),
        .o_instruction      (           ),
        .o_rs               (o_data     ),
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