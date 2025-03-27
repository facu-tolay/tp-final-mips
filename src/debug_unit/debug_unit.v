module debug_unitold
#
(
    parameter NB_DATA       = 32    ,
    parameter NB_BYTE       = 8     ,
    parameter N_REGISTERS   = 32    ,
    parameter NB_STATE      = 3
)
(
    output wire                                 o_uart_tx_data      ,
    output wire                                 o_execution_mode    ,
    output wire                                 o_execution_step    ,
    output wire                                 o_du_done           , // indica cuando termino el proceso de enviar la data
    output wire [NB_STATE               -1 : 0] o_state             ,

    input wire                                  i_uart_rx_data      ,
    input wire                                  i_halt              ,
    input wire  [NB_DATA                -1 : 0] i_pc                ,
    input wire  [NB_DATA                -1 : 0] i_data_memory       ,
    input wire  [NB_DATA                -1 : 0] i_cycles            ,
    input wire  [N_REGISTERS * NB_DATA  -1 : 0] i_registers         ,
    input wire                                  i_reset             ,
    input wire                                  i_clock
);

    wire [NB_BYTE       -1 : 0] uart_data_receive;
    wire [NB_BYTE       -1 : 0] data_uart_send;
    wire [NB_DATA       -1 : 0] uart_data_send_32b;
    wire [NB_STATE      -1 : 0] state;
    wire                        uart_rx_done;
    wire                        uart_tx_done;
    wire                        uart_tx_done_8b;
    wire                        uart_tx_done_32b;
    wire                        uart_tx_start;
    wire                        uart_tx_start_8b;
    wire                        uart_tx_start_32b;
    wire                        du_done;
    wire                        execution_mode;
    wire                        execution_step;
    wire                        halt;

    // --------------------------------------------------
    // UART
    // --------------------------------------------------
    uart_32b u_uart
    (
        .o_data                         (uart_data_receive  ),
        .o_rx_done_pulse                (uart_rx_done       ),
        .o_tx                           (o_uart_tx_data     ),
        .o_tx_done_8b_pulse             (uart_tx_done_8b    ),
        .o_tx_done_32b_pulse            (uart_tx_done_32b   ),

        .i_rx                           (i_uart_rx_data     ),
        .i_tx_data                      (uart_data_send_32b ),
        .i_tx_start_8b                  (uart_tx_start_8b   ),
        .i_tx_start_32b                 (uart_tx_start_32b  ),
        .i_reset                        (i_reset            ),
        .i_clock                        (i_clock            )
    );

    // --------------------------------------------------
    // TX Debug Unit
    // --------------------------------------------------
    debug_unit_transmit du_transmit
    (
        .o_uart_data_to_send            (uart_data_send_32b ),
        .o_uart_tx_8b_start             (uart_tx_start_8b   ),
        .o_uart_tx_32b_start            (uart_tx_start_32b  ),
        .o_done                         (du_done            ),

        .i_pc                           (i_pc               ),
        .i_registers                    (i_registers        ),
        .i_data_memory                  (i_data_memory      ),
        .i_cycles                       (i_cycles           ),
        .i_uart_tx_done                 (                   ), // FIXME borrar
        .i_uart_tx_8b_done              (uart_tx_done_8b    ),
        .i_uart_tx_32b_done             (uart_tx_done_32b   ),
        .i_execution_mode               (execution_mode     ),
        .i_step                         (execution_step     ),
        .i_halt                         (i_halt             ),
        .i_reset                        (i_reset            ),
        .i_clock                        (i_clock            )
    );

    // --------------------------------------------------
    // RX Debug Unit
    // --------------------------------------------------
    debug_unit_receive du_receive
    (
        .o_execution_mode               (execution_mode     ),
        .o_execution_step               (execution_step     ),
        .o_state                        (state              ),

        .i_rx_data                      (uart_data_receive  ),
        .i_rx_done                      (uart_rx_done       ),
        .i_reset                        (i_reset            ),
        .i_clock                        (i_clock            )
    );

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_execution_mode = execution_mode;
    assign o_execution_step = execution_step;
    assign o_du_done        = du_done;
    assign o_state          = state;

endmodule