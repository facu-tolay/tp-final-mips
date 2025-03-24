`timescale 1ns / 1ps

module uart_32b
#(
    parameter   NB_DATA         = 32                ,
    parameter   NB_BYTE         = 8                 ,
    parameter   BAUD_RATE       = 9600              ,
    parameter   CLOCK_FREQ_HZ   = 25000000
)
(
    output wire                     o_tx                ,
    output wire [NB_BYTE   - 1 : 0] o_data              ,
    output wire                     o_tx_done_8b_pulse  ,
    output wire                     o_tx_done_32b_pulse ,
    output wire                     o_rx_done_pulse     ,

    input wire                      i_rx                ,
    input wire  [NB_DATA   - 1 : 0] i_tx_data           ,
    input wire                      i_tx_start_8b       ,
    input wire                      i_tx_start_32b      ,
    input wire                      i_reset             ,
    input wire                      i_clock
);

    wire [NB_BYTE -1 : 0]   uart_byte_tx_data;
    wire                    uart_byte_tx_done;
    wire                    uart_tx_start;
    wire                    baud_rate_tick;

    baud_rate_generator u_baud_rate_generator
    (
        .o_clock_tick       (baud_rate_tick         ),

        .i_reset            (i_reset                ),
        .i_clock            (i_clock                )
    );

    receiver u_receiver
    (
        .o_rx_done          (o_rx_done_pulse        ),
        .o_data             (o_data                 ),

        .i_rx               (i_rx                   ),
        .i_signal_tick      (baud_rate_tick         ),
        .i_reset            (i_reset                ),
        .i_clock            (i_clock                )
    );

    transmitter u_transmitter
    (
        .o_tx               (o_tx                   ),
        .o_tx_done          (uart_byte_tx_done      ),

        .i_tx_data          (uart_byte_tx_data      ),
        .i_tx_start         (uart_tx_start          ),
        .i_signal_tick      (baud_rate_tick         ),
        .i_reset            (i_reset                ),
        .i_clock            (i_clock                )
    );

    word_transmitter u_word_transmitter
    (
        .o_tx_data          (uart_byte_tx_data      ),
        .o_tx_start         (uart_tx_start          ),
        .o_tx_done_8b       (o_tx_done_8b_pulse     ),
        .o_tx_done_32b      (o_tx_done_32b_pulse    ),

        .i_tx_data          (i_tx_data              ),
        .i_tx_done          (uart_byte_tx_done      ),
        .i_tx_8b_start      (i_tx_start_8b          ),
        .i_tx_32b_start     (i_tx_start_32b         ),
        .i_reset            (i_reset                ),
        .i_clock            (i_clock                )
    );

endmodule
