`timescale 1ns / 1ps

// prueba TX solo con i_halt = true

module tb_debug_unit_00();

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
