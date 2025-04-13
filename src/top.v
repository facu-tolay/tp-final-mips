`timescale 1ns / 1ps

module top
#(
    parameter NB_DATA                   = 32    ,
    parameter NB_BYTE                   = 8     ,
    parameter NB_REG_ADDRESS            = 5     ,
    parameter NB_MEM_ADDRESS            = 7     ,
    parameter N_STAGES_TRANSITIONS      = 5
)
(
    output wire [NB_DATA/2 -1 : 0]  o_leds                  ,
    output wire                     o_uart_tx               ,
    output wire                     o_program_loaded        ,
    output wire                     o_program_ended         ,
    output wire                     o_test                  ,

    input  wire                     i_test                  ,
    input  wire                     i_uart_rx               ,
    input  wire                     i_reset                 ,
    input  wire                     i_clock
);

    wire    [NB_DATA              -1 : 0]   debug_read_reg;
    wire    [NB_DATA              -1 : 0]   debug_read_mem;
    wire    [NB_DATA              -1 : 0]   debug_read_pc;
    wire                                    clock_1_2;

    wire    [N_STAGES_TRANSITIONS -1 : 0]   enable_stages_transitions;
    wire                                    is_program_end;
    wire                                    pc_reset;
    wire                                    delete_program;

    wire    [NB_REG_ADDRESS       -1 : 0]   debug_read_reg_address;
    wire    [NB_MEM_ADDRESS       -1 : 0]   debug_read_mem_address;

    wire    [NB_BYTE              -1 : 0]   load_program_byte;
    wire                                    load_program_write_enable;

    wire    [NB_DATA              -1 : 0]   uart_data_to_send;
    wire    [NB_BYTE              -1 : 0]   uart_receive_byte;
    wire                                    uart_receive_byte_done;
    wire                                    uart_enable_send_data;
    wire                                    uart_tx_done;

    // --------------------------------------------------
    // Main clock divider 1/2
    // --------------------------------------------------
    clock_divider u_clock_divider
    (
        .o_clock_div                    (clock_1_2                  ),
        .i_reset                        (1'b0                       ),
        .i_clock                        (i_clock                    )
    );

    // --------------------------------------------------
    // MIPS
    // --------------------------------------------------
    mips u_mips
    (
        .o_debug_read_reg               (debug_read_reg             ),
        .o_debug_read_mem               (debug_read_mem             ),
        .o_debug_read_pc                (debug_read_pc              ),
        .o_is_program_end               (is_program_end             ),

        .i_debug_read_reg_address       (debug_read_reg_address     ),
        .i_debug_read_mem_address       (debug_read_mem_address     ),
        .i_enable_stages_transitions    (enable_stages_transitions  ),
        .i_load_program_byte            (load_program_byte          ),
        .i_load_program_write_enable    (load_program_write_enable  ),
        .i_pc_reset                     (pc_reset                   ),
        .i_delete_program               (delete_program             ),
        .i_reset                        (i_reset                    ),
        .i_clock                        (clock_1_2                  )
    );

    // --------------------------------------------------
    // Debug Unit
    // --------------------------------------------------
    debug_unit u_debug_unit
    (
        // UART communication
        .i_uart_receive_byte            (uart_receive_byte          ),
        .i_uart_receive_byte_done       (uart_receive_byte_done     ),
        .i_uart_tx_done                 (uart_tx_done               ),
        .o_uart_data_to_send            (uart_data_to_send          ),
        .o_uart_enable_send_data        (uart_enable_send_data      ),

        // Stages transitions
        .o_enable_stages_transitions    (enable_stages_transitions  ),

        // Registers read
        .i_debug_read_reg               (debug_read_reg             ),
        .o_debug_read_reg_address       (debug_read_reg_address     ),

        // Memory read
        .i_debug_read_mem               (debug_read_mem             ),
        .o_debug_read_mem_address       (debug_read_mem_address     ),

        // PC operations
        .i_debug_read_pc                (debug_read_pc              ),
        .o_pc_reset                     (pc_reset                   ),

        // Program operations
        .o_load_program_byte            (load_program_byte          ),
        .o_load_program_write_enable    (load_program_write_enable  ),
        .o_program_loaded               (o_program_loaded           ),
        .o_delete_program               (delete_program             ),
        .i_mips_program_ended           (is_program_end             ),

        // Status
        .o_leds                         (o_leds                     ),

        .i_reset                        (i_reset                    ),
        .i_clock                        (clock_1_2                  )
    );

    // --------------------------------------------------
    // UART
    // --------------------------------------------------
    uart_32b u_uart
    (
        .o_data                         (uart_receive_byte          ),
        .o_rx_done_pulse                (uart_receive_byte_done     ),
        .o_tx                           (o_uart_tx                  ),
        .o_tx_done_8b_pulse             (                           ),
        .o_tx_done_32b_pulse            (uart_tx_done               ),

        .i_rx                           (i_uart_rx                  ),
        .i_tx_data                      (uart_data_to_send          ),
        .i_tx_start_8b                  (1'b0                       ),
        .i_tx_start_32b                 (uart_enable_send_data      ),
        .i_reset                        (i_reset                    ),
        .i_clock                        (clock_1_2                  )
    );

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign  o_test              = i_test;
    assign  o_program_ended     = is_program_end;

endmodule
