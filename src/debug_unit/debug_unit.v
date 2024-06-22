module debug_unit
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

    wire [NB_BYTE       -1 : 0] data_uart_receive;
    wire [NB_BYTE       -1 : 0] data_uart_send;
    wire [NB_STATE      -1 : 0] state;
    wire                        uart_rx_done;
    wire                        uart_tx_done;
    wire                        uart_tx_start;
    wire                        execution_mode;
    wire                        execution_step;
    wire                        halt;

    // --------------------------------------------------
    // UART
    // --------------------------------------------------
    uart u_uart
    (
        .o_tx                           (o_uart_tx_data     ),
        .o_data                         (data_uart_receive  ),
        .o_tx_done_pulse                (uart_tx_done       ),
        .o_rx_done_pulse                (uart_rx_done       ),

        .i_rx                           (i_uart_rx_data     ),
        .i_tx_data                      (data_uart_send     ),
        .i_tx_start                     (uart_tx_start      ),
        .i_reset                        (i_reset            ),
        .i_clock                        (i_clock            )
    );

    // --------------------------------------------------
    // TX Debug Unit
    // --------------------------------------------------
    debug_unit_transmit du_transmit
    (
        .o_uart_data_to_send            (data_uart_send     ),
        .o_uart_tx_start                (uart_tx_start      ),
        .o_done                         (done               ),
        .o_state                        (                   ),

        .i_execution_mode               (execution_mode     ),
        .i_step                         (execution_step     ),
        .i_halt                         (i_halt             ),
        .i_pc                           (i_pc               ),
        .i_data_memory                  (i_data_memory      ),
        .i_cycles                       (i_cycles           ),
        .i_registers                    (i_registers        ),
        .i_uart_tx_done                 (uart_tx_done       ),
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

        .i_rx_data                      (data_uart_receive  ),
        .i_rx_done                      (uart_rx_done       ),
        .i_reset                        (i_reset            ),
        .i_clock                        (i_clock            )
    );

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_execution_mode = execution_mode;
    assign o_execution_step = execution_step;
    assign o_du_done        = done;
    assign o_state          = state;
    // assign o_state[0]       = data_uart_receive[0];
    // assign o_state[1]       = data_uart_receive[1];
    // assign o_state[2]       = uart_rx_done;

endmodule