`timescale 1ns / 1ps

// prueba TX solo con i_halt = true

module tb_debug_unit_00();

    localparam NB_DATA       = 32;
    localparam NB_REGISTER   = 5;
    localparam NB_STATE      = 4;
    localparam NB_BYTE       = 8;
    localparam N_CLOCKS_BETWEEN_DATA = 4;

    `include "common_defs.v"
    // `include "uart_utils.v"

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------
    wire                    uart_tx_data;
    wire                    execution_mode;
    wire                    execution_step;
    wire                    du_done;
    reg  [NB_DATA   -1 : 0] pc;
    reg  [NB_DATA   -1 : 0] data_memory;
    reg  [NB_DATA   -1 : 0] cycles;
    reg  [NB_DATA   -1 : 0] registers;
    reg                     halt;

    suodv2 u_suodv2(
            clk_out64MHz, i_reset, is_end_de_mips_a_suod, uart_tx_done_32b,
            orden_de_uart_a_suod,
            enable_de_suod_a_sepador,
            palabra_de_suod_a_separador,
    //Enable para los latch
            enable_latch_de_suod_a_mips,
    // Lectura en registros
            debug_read_reg_de_mips_a_suod,
            debug_direcc_reg_de_suod_a_mips,
    // Lectura en memoria
            debug_read_mem_de_mips_a_suod,
            debug_direcc_mem_de_suod_a_mips, //TODO: o_debug_direcc_mem_de_suod_a_mips?
    // interaccion con el pc
            debug_read_pc_de_mips_a_suod,
            pc_reset_de_mips_a_suod,
            borrar_programa_de_mips_a_suod,
    // Escritura de la memoria de boot
            fifo_vacia_de_uart_a_suod,
            read_enable_de_suod_a_uart,
            enable_write_de_suod_a_bootloader,
            byte_de_suod_a_bootloader,
            o_programa_cargado,
            o_programa_no_cargado,
            o_leds     
        );       
     
     // separador_bytes separadorDeBytes(
     //    clk_out64MHz, i_reset,
     //    palabra_de_suod_a_separador,
     //    enable_de_suod_a_sepador,
    
     //    byte_de_separador_a_uart,
     //    enable_de_sepador_a_uart
     // );

    // --------------------------------------------------
    // UART
    // --------------------------------------------------
    wire uart_tx_done_32b;

    uart_32b u_uart
    (
        .o_data                 (orden_de_uart_a_suod       ),
        .o_rx_done_pulse        (~fifo_vacia_de_uart_a_suod ),
        .o_tx                   (o_Tx                       ),
        .o_tx_done_8b_pulse     (                           ),
        .o_tx_done_32b_pulse    (uart_tx_done_32b           ),

        .i_rx                   (i_Rx                       ),
        .i_tx_data              (palabra_de_suod_a_separador),
        .i_tx_start_8b          (1'b0                       ),
        .i_tx_start_32b         (enable_de_suod_a_sepador   ),
        .i_reset                (i_reset                    ),
        .i_clock                (clk_out64MHz               )
    );

    initial begin

        pc              = 32'hAABBCCDD;
        data_memory     = 32'h00110011;
        cycles          = 32'h44444444;
        registers       = 32'hB0B0B0B0;
        halt            = 1'b0;

        $display("############# Test START ############\n");
        test_startup();

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        halt = 1'b1;
        @(posedge clock);
        halt = 1'b0;

        // send_data_to_rx(8'hFF);
        repeat(650*16*256) begin
            @(posedge clock);
        end

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        #10

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule
