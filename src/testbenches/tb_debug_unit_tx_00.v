`timescale 1ns / 1ps


module tb_debug_unit_tx_00();

    localparam NB_DATA       = 32;
    localparam NB_REGISTER   = 5;
    localparam NB_STATE      = 4;
    localparam NB_BYTE       = 8;
    localparam N_CLOCKS_BETWEEN_DATA = 4;

    `include "common_defs.v"

    // --------------------------------------------------
    // Simulate sending UART data to debug unit
    // --------------------------------------------------
    task send_step_to_du_tx;
        begin
            execution_mode  = 1'b1;
            step            = 1'b1;
            @(posedge clock);
            step            = 1'b0;
        end
    endtask

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------

    wire [NB_DATA       -1 : 0] uart_data_to_send;
    wire                        uart_tx_8b_start;
    wire                        uart_tx_32b_start;
    wire                        done;

    reg                         uart_tx_32b_done;
    reg                         uart_tx_8b_done;
    reg                         execution_mode;
    reg                         step;
    reg                         halt;

    debug_unit_transmit du_transmit
    (
        .o_uart_data_to_send    (uart_data_to_send  ),
        .o_uart_tx_8b_start     (uart_tx_8b_start   ),
        .o_uart_tx_32b_start    (uart_tx_32b_start  ),
        .o_done                 (done               ),

        .i_pc                   (32'hAABBCCDD       ),
        .i_registers            (32'hEEFFDDCC       ),
        .i_data_memory          (32'h11223344       ),
        .i_cycles               (32'h55667788       ),
        .i_uart_tx_done         (                   ),
        .i_uart_tx_32b_done     (uart_tx_32b_done   ),
        .i_uart_tx_8b_done      (uart_tx_8b_done    ),
        .i_execution_mode       (execution_mode     ),
        .i_step                 (step               ),
        .i_halt                 (halt               ),
        .i_reset                (reset              ),
        .i_clock                (clock              )
    );

    initial begin

        uart_tx_32b_done    = 1'b0;
        uart_tx_8b_done     = 1'b0;
        execution_mode      = 1'b0;
        step                = 1'b0;
        halt                = 1'b0;

        $display("############# Test START ############\n");
        test_startup();

        send_step_to_du_tx();
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        uart_tx_32b_done = 1'b1;
        @(posedge clock);
        uart_tx_32b_done = 1'b0;

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        uart_tx_32b_done = 1'b1;
        @(posedge clock);
        uart_tx_32b_done = 1'b0;

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        uart_tx_32b_done = 1'b1;
        @(posedge clock);
        uart_tx_32b_done = 1'b0;

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        uart_tx_32b_done = 1'b1;
        @(posedge clock);
        uart_tx_32b_done = 1'b0;

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
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
