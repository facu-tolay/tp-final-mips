`timescale 1ns / 1ps


module top
#(
    parameter   NB_DATA   = 6
)
(
    output wire                     o_uart_tx_data  ,
    output wire [NB_DATA - 1 : 0]   o_data          ,

    input wire                      i_uart_rx_data  ,
    input wire                      i_switch        ,
    input wire                      i_reset         ,
    input wire                      i_clock

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

    // --------------------------------------------------
    // Fetch stage
    // --------------------------------------------------
    // fetch_stage
    // #(
    // )
    // u_fetch_stage
    // (
    //     .o_pc_next          (           ),
    //     .o_instruction      (           ),
    //     .o_rs               (o_data[4:0]),
    //     .o_rt               (           ),

    //     .i_pc_next          (           ),
    //     .i_stall            (1'b0       ),
    //     .i_pc_src           (1'b0       ),
    //     .i_valid            (1'b1       ),
    //     .i_clock            (i_clock    ),
    //     .i_reset            (i_reset    )
    // );

    // --------------------------------------------------
    // UART
    // --------------------------------------------------
    wire tx_done_uart;
    wire rx_done_uart;
    wire [8-1 : 0] data_uart_receive;
    uart u_uart
    (
        .o_tx                       (o_uart_tx_data         ),
        .o_data                     (data_uart_receive      ),
        .o_tx_done_pulse            (tx_done_uart           ),
        .o_rx_done_pulse            (rx_done_uart           ),

        .i_rx                       (i_uart_rx_data         ),
        .i_tx_data                  (8'b00                  ),
        .i_tx_start                 (1'b0                   ),
        .i_reset                    (i_reset                ),
        .i_clock                    (i_clock                )
    );

    // --------------------------------------------------
    // Output block
    // --------------------------------------------------
    // assign o_data           = data_result           ;

endmodule