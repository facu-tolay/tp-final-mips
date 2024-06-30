`timescale 1ns / 1ps


module tb_debug_unit_rx_00();

    localparam NB_DATA       = 32;
    localparam NB_REGISTER   = 5;
    localparam NB_STATE      = 3;
    localparam NB_BYTE       = 8;
    localparam N_CLOCKS_BETWEEN_DATA = 4;

    `include "common_defs.v"

    // --------------------------------------------------
    // Simulate sending UART data to debug unit
    // --------------------------------------------------
    task send_uart_data_to_du;
        input [NB_BYTE-1 : 0] uart_data_to_du;

        begin
            data_uart_receive = uart_data_to_du;
            uart_rx_done      = 1'b1;
            @(posedge clock);
            uart_rx_done      = 1'b0;
        end
    endtask

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------
    reg  [NB_BYTE       -1 : 0] data_uart_receive;
    reg                         uart_rx_done;
    wire [NB_STATE      -1 : 0] state;
    wire [NB_DATA       -1 : 0] data_memory;
    wire                        enable_write_memory;
    wire                        done_write_memory;
    wire                        execution_mode;
    wire                        execution_step;

    debug_unit_receive du_receive
    (
        .o_execution_mode               (execution_mode         ),
        .o_execution_step               (execution_step         ),
        .o_enable_write_memory          (enable_write_memory    ),
        .o_done_write_memory            (done_write_memory      ),
        .o_data_memory                  (data_memory            ),
        .o_state                        (state                  ),

        .i_rx_data                      (data_uart_receive      ),
        .i_rx_done                      (uart_rx_done           ),
        .i_reset                        (reset                  ),
        .i_clock                        (clock                  )
    );

    initial begin

        valid               = 1'b0;
        data_uart_receive   = 8'b0;
        uart_rx_done        = 1'b0;

        $display("############# Test START ############\n");
        test_startup();

        send_uart_data_to_du(8'h55); // send command to start instruction load

        `assert(enable_write_memory == 1'b1);

        send_uart_data_to_du(8'hAA);
        send_uart_data_to_du(8'hBB);
        send_uart_data_to_du(8'hCC);
        send_uart_data_to_du(8'hDD);

        `assert(enable_write_memory == 1'b1);
        `assert(done_write_memory   == 1'b1);
        `assert(data_memory         == 32'hAABBCCDD);

        send_uart_data_to_du(8'h11);
        send_uart_data_to_du(8'h22);
        send_uart_data_to_du(8'h33);
        send_uart_data_to_du(8'h44);

        `assert(enable_write_memory == 1'b1);
        `assert(done_write_memory   == 1'b1);
        `assert(data_memory         == 32'h11223344);

        send_uart_data_to_du(8'h1F);
        send_uart_data_to_du(8'h2F);
        send_uart_data_to_du(8'h3F);
        send_uart_data_to_du(8'h4F);

        `assert(enable_write_memory == 1'b1);
        `assert(done_write_memory   == 1'b1);
        `assert(data_memory         == 32'h1F2F3F4F);

        // envio el halt, verificar que enable_write_memory = 0
        send_uart_data_to_du(8'hFF);
        send_uart_data_to_du(8'hFF);
        send_uart_data_to_du(8'hFF);
        send_uart_data_to_du(8'hFF);

        `assert(enable_write_memory == 1'b1);
        `assert(done_write_memory   == 1'b1);
        `assert(data_memory         == 32'hFFFFFFFF);

        // enviar el modo de ejecucion
        send_uart_data_to_du(8'h01);

        `assert(enable_write_memory == 1'b0);
        `assert(execution_mode      == 1'b1);

        // verifica los pulsos de step
        @(posedge clock);
        @(posedge clock);
        send_uart_data_to_du(8'h01);
        `assert(execution_step      == 1'b1);

        @(posedge clock);
        @(posedge clock);
        send_uart_data_to_du(8'h01);
        `assert(execution_step      == 1'b1);

        #10

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule
