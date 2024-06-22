`timescale 1ns / 1ps


module top
#(
    parameter   NB_DATA     = 6     ,
    parameter   NB_DISPLAY  = 7
)
(
    output wire                             o_uart_tx_data  ,
    output wire [NB_DATA        - 1 : 0]    o_data          ,
    output wire [NB_DISPLAY     - 1 : 0]    o_display       ,
    output wire                             o_display_enable,

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
        .o_execution_mode   (o_data[5]              ), // si es continuo o paso a paso
        .o_execution_step   (o_data[4]              ), // ejecutar un paso
        .o_du_done          (o_data[3]              ), // indica cuando termino el proceso de enviar
        .o_state            (o_data[2:0]            ),

        .i_uart_rx_data     (i_uart_rx_data         ),
        .i_halt             (1'b0                   ),
        .i_pc               (32'b0                  ),
        .i_data_memory      (32'b0                  ),
        .i_cycles           (32'b0                  ),
        .i_registers        (1024'b0                ),
        .i_reset            (i_reset                ),
        .i_clock            (i_clock                )
    );

    // --------------------------------------------------
    // Output block
    // --------------------------------------------------
    // reg display_enable;
    // always @(posedge i_clock) begin
    //     if(i_reset) begin
    //          display_enable <= 1'b0;
    //     end
    //     else begin
    //          display_enable <= 1'b0;
    //     end
    // end

    assign o_display_enable = 1'b1;
    assign o_display        = 7'h7F;

endmodule