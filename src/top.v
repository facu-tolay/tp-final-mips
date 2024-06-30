`timescale 1ns / 1ps


module top
#(
    parameter   NB_DATA     = 6     ,
    parameter   NB_DISPLAY  = 7
)
(
    output wire                             o_uart_tx_data  ,
    output wire [NB_DATA        - 1 : 0]    o_data          ,

    input wire                              i_uart_rx_data  ,
    input wire                              i_switch        ,
    input wire                              i_reset         ,
    input wire                              i_clock
);

    // --------------------------------------------------
    // Debug Unit
    // --------------------------------------------------
    debug_unit u_debug_unit
    (
        .o_uart_tx_data     (o_uart_tx_data         ),
        .o_execution_mode   (o_data[3]              ),
        .o_execution_step   (o_data[4]              ),
        .o_du_done          (o_data[5]              ),
        .o_state            (o_data[2:0]            ),

        .i_uart_rx_data     (i_uart_rx_data         ),
        .i_halt             (1'b0                   ),
        .i_pc               (32'hAABBCCDD           ),
        .i_data_memory      (32'h11223344           ),
        .i_cycles           (32'h11001100           ),
        .i_registers        (32'hFFFFFFFF           ),
        .i_reset            (i_reset                ),
        .i_clock            (i_clock                )
    );

endmodule