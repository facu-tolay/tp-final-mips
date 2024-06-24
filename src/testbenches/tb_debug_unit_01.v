`timescale 1ns / 1ps

// prueba TX solo con UART para setear execution_mode = true y steps

module tb_debug_unit_01();

    localparam NB_DATA       = 32;
    localparam NB_REGISTER   = 5;
    localparam NB_STATE      = 4;
    localparam NB_BYTE       = 8;
    localparam N_CLOCKS_BETWEEN_DATA = 4;

    `include "common_defs.v"
    `include "uart_utils.v"

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

    debug_unit u_debug_unit
    (
        .o_uart_tx_data         (uart_tx_data       ),
        .o_execution_mode       (execution_mode     ),
        .o_execution_step       (execution_step     ),
        .o_du_done              (du_done            ),
        .o_state                (                   ),

        .i_uart_rx_data         (rx_data            ),
        .i_halt                 (halt               ),
        .i_pc                   (pc                 ),
        .i_data_memory          (data_memory        ),
        .i_cycles               (cycles             ),
        .i_registers            (registers          ),
        .i_reset                (reset              ),
        .i_clock                (clock              )
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


        // 1) enviar comando de start load program
        send_data_to_rx(8'h55);

        // 2) enviar N instrucciones de 4 bytes
        send_data_to_rx(8'hAA);
        send_data_to_rx(8'hBB);
        send_data_to_rx(8'hCC);
        send_data_to_rx(8'hDD);

        send_data_to_rx(8'h11);
        send_data_to_rx(8'h22);
        send_data_to_rx(8'h33);
        send_data_to_rx(8'h44);

        send_data_to_rx(8'h66);
        send_data_to_rx(8'h77);
        send_data_to_rx(8'h88);
        send_data_to_rx(8'h99);

        send_data_to_rx(8'h00);
        send_data_to_rx(8'h11);
        send_data_to_rx(8'h00);
        send_data_to_rx(8'h11);

        send_data_to_rx(8'hB0);
        send_data_to_rx(8'hB0);
        send_data_to_rx(8'hB0);
        send_data_to_rx(8'hB0);

        // 3) enviar fin de programa
        send_data_to_rx(8'hFF);
        send_data_to_rx(8'hFF);
        send_data_to_rx(8'hFF);
        send_data_to_rx(8'hFF);

        // 4) setear el modo de ejecucion a STEP-BY-STEP
        send_data_to_rx(8'h01);

        // 5) enviar pasos
        repeat(30) begin
            @(posedge clock);
        end
        send_data_to_rx(8'h01);

        // 5.1) esperar que se termine de transmitir todo y mandar otro paso
        repeat(650*16*256) begin
            @(posedge clock);
        end
        send_data_to_rx(8'h01);

        // 5.2) esperar que se termine de transmitir todo
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
