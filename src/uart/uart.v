`timescale 1ns / 1ps

module uart
#(
    parameter   NB_DATA         = 8                 ,
    parameter   BAUD_RATE       = 9600              ,
    parameter   CLOCK_FREQ_HZ   = 100000000
)
(
    output wire                     o_tx            ,
    output wire [NB_DATA   - 1 : 0] o_data          ,
    output wire                     o_tx_done_pulse ,
    output wire                     o_rx_done_pulse ,

    input wire                      i_rx            ,
    input wire  [NB_DATA   - 1 : 0] i_tx_data       ,
    input wire                      i_tx_start      ,
    input wire                      i_reset         ,
    input wire                      i_clock
);

    wire baud_rate_tick;

    baud_rate_generator u_baud_rate_generator
    (
        .o_clock_tick       (baud_rate_tick     ),

        .i_reset            (i_reset            ),
        .i_clock            (i_clock            )
    );

    receiver u_receiver
    (
        .o_rx_done          (o_rx_done_pulse    ),
        .o_data             (o_data             ),

        .i_rx               (i_rx               ),
        .i_signal_tick      (baud_rate_tick     ),
        .i_reset            (i_reset            ),
        .i_clock            (i_clock            )
    );

    transmitter u_transmitter
    (
        .o_tx               (o_tx               ),
        .o_tx_done          (o_tx_done_pulse    ),

        .i_tx_data          (i_tx_data          ),
        .i_tx_start         (i_tx_start         ),
        .i_signal_tick      (baud_rate_tick     ),
        .i_reset            (i_reset            ),
        .i_clock            (i_clock            )
    );

endmodule
