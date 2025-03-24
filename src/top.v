`timescale 1ns / 1ps

module top
#(
    parameter NB_DATA                   = 32    ,
    parameter NB_BYTE                   = 8     ,
    parameter NB_REG_ADDRESS            = 5     ,
    parameter NB_MEM_ADDRESS            = 7     ,
    parameter N_STAGES_TRANSITIONS      = 5     ,

    parameter NB_JUMP_FIELD             = 26    ,
    parameter NB_OP_FIELD               = 5     ,
    parameter NB_SIGNALS                = 18
)
(
    output wire [NB_DATA/2 -1 : 0]  o_leds                  ,
    output wire                     o_Tx                    ,
    output wire                     o_programa_cargado      ,
    output wire                     o_programa_no_cargado   ,
    output wire                     o_programa_terminado    ,
    output wire                     o_test                  ,

    input  wire                     i_test                  ,
    input  wire                     i_Rx                    ,
    input  wire                     i_reset                 ,
    input  wire                     i_clock
);

    wire    [NB_DATA              -1 : 0]   debug_read_reg_de_mips_a_suod;
    wire    [NB_DATA              -1 : 0]   debug_read_mem_de_mips_a_suod;
    wire    [NB_DATA              -1 : 0]   debug_read_pc_de_mips_a_suod;
    wire                                    uart_tx_done_32b;
    wire                                    clock_1_4;

    wire                                    is_end_de_mips_a_suod;
    wire                                    enable_write_de_suod_a_bootloader;
    wire                                    pc_reset_de_mips_a_suod;
    wire                                    borrar_programa_de_mips_a_suod;
    wire                                    enable_de_suod_a_sepador;

    wire    [NB_REG_ADDRESS       -1 : 0]   debug_direcc_reg_de_suod_a_mips;
    wire    [NB_MEM_ADDRESS       -1 : 0]   debug_direcc_mem_de_suod_a_mips;

    wire    [NB_BYTE              -1 : 0]   byte_de_suod_a_bootloader;
    wire    [N_STAGES_TRANSITIONS -1 : 0]   enable_latch_de_suod_a_mips;

    wire    [NB_DATA              -1 : 0]   palabra_de_suod_a_separador;
    wire    [NB_BYTE              -1 : 0]   orden_de_uart_a_suod;
    wire                                    fifo_vacia_de_uart_a_suod;

    // --------------------------------------------------
    // Main clock divider 1/4
    // --------------------------------------------------
    clock_divider u_clock_div
    (
        .o_clock_div            (clock_1_4                          ),
        .i_reset                (1'b0                               ),
        .i_clock                (i_clock                            )
    );

    // --------------------------------------------------
    // MIPS
    // --------------------------------------------------
    mips u_mips
    (
        .o_is_end               (is_end_de_mips_a_suod              ),
        .o_debug_read_reg       (debug_read_reg_de_mips_a_suod      ),
        .o_debug_read_mem       (debug_read_mem_de_mips_a_suod      ),
        .o_read_debug_pc        (debug_read_pc_de_mips_a_suod       ),

        .i_bootload_wr_en       (enable_write_de_suod_a_bootloader  ),
        .i_pc_reset             (pc_reset_de_mips_a_suod            ),
        .i_borrar_programa      (borrar_programa_de_mips_a_suod     ),
        .i_latches_en           (enable_latch_de_suod_a_mips        ),
        .i_bootload_byte        (byte_de_suod_a_bootloader          ),
        .i_debug_ptr_mem        (debug_direcc_mem_de_suod_a_mips    ),
        .i_debug_ptr_reg        (debug_direcc_reg_de_suod_a_mips    ),
        .i_reset                (i_reset                            ),
        .i_clk                  (clock_1_4                          )
    );

    // --------------------------------------------------
    // Debug Unit
    // --------------------------------------------------
    suodv2 u_suodv2
    (
        // Control y transmision de datos
        .i_is_end               (is_end_de_mips_a_suod              ),
        .i_tx_done_32b_word     (uart_tx_done_32b                   ),
        .i_orden                (orden_de_uart_a_suod               ),
        .o_enable_enviada_data  (enable_de_suod_a_sepador           ),
        .o_data_enviada         (palabra_de_suod_a_separador        ),

        // Enable para los latch
        .o_enable_latch         (enable_latch_de_suod_a_mips        ),

        // Lectura en registros
        .i_debug_read_reg       (debug_read_reg_de_mips_a_suod      ),
        .o_debug_direcc_reg     (debug_direcc_reg_de_suod_a_mips    ),

        // Lectura en memoria
        .i_debug_read_mem       (debug_read_mem_de_mips_a_suod      ),
        .o_debug_direcc_mem     (debug_direcc_mem_de_suod_a_mips    ),

        // interaccion con el PC
        .i_read_pc              (debug_read_pc_de_mips_a_suod       ),
        .o_pc_reset             (pc_reset_de_mips_a_suod            ),
        .o_borrar_programa      (borrar_programa_de_mips_a_suod     ),

        // Escritura de la memoria de boot
        .i_fifo_empty           (~fifo_vacia_de_uart_a_suod         ),
        .o_read_enable          (read_enable_de_suod_a_uart         ), // FIXME unused - sacar
        .o_bootload_write       (enable_write_de_suod_a_bootloader  ),
        .o_bootload_byte        (byte_de_suod_a_bootloader          ),
        .o_programa_cargado     (o_programa_cargado                 ),
        .o_programa_no_cargado  (o_programa_no_cargado              ),
        .o_leds                 (o_leds                             ),

        .i_reset                (i_reset                            ),
        .i_clk                  (clock_1_4                          )
    );

    // --------------------------------------------------
    // UART
    // --------------------------------------------------
    uart_32b u_uart
    (
        .o_data                 (orden_de_uart_a_suod               ),
        .o_rx_done_pulse        (fifo_vacia_de_uart_a_suod          ),
        .o_tx                   (o_Tx                               ),
        .o_tx_done_8b_pulse     (                                   ),
        .o_tx_done_32b_pulse    (uart_tx_done_32b                   ),

        .i_rx                   (i_Rx                               ),
        .i_tx_data              (palabra_de_suod_a_separador        ),
        .i_tx_start_8b          (1'b0                               ),
        .i_tx_start_32b         (enable_de_suod_a_sepador           ),
        .i_reset                (i_reset                            ),
        .i_clock                (clock_1_4                          )
    );

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign  o_test                  = i_test;
    assign  o_programa_terminado    = is_end_de_mips_a_suod;

endmodule
