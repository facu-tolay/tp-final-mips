`timescale 1ns / 1ps


module tb_uart_word_transmitter_00();

    localparam NB_DATA       = 32;
    localparam NB_BYTE       = 8;

    `include "common_defs.v"

    // --------------------------------------------------
    // Simulate sending UART data to debug unit
    // --------------------------------------------------
    task send_8b_data_to_word_transmitter;
        input [NB_DATA-1 : 0] data_word_to_transmit;

        begin
            tx_data_word    = data_word_to_transmit;
            tx_8b_start     = 1'b1;
            @(posedge clock);
            tx_8b_start     = 1'b0;
        end
    endtask

    task send_32b_data_to_word_transmitter;
        input [NB_DATA-1 : 0] data_word_to_transmit;

        begin
            tx_data_word    = data_word_to_transmit;
            tx_32b_start    = 1'b1;
            @(posedge clock);
            tx_32b_start    = 1'b0;
        end
    endtask

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------
    wire [NB_BYTE       -1 : 0] uart_tx_data;
    wire                        uart_tx_start;
    wire                        uart_tx_8b_done;
    wire                        uart_tx_32b_done;
    reg  [NB_DATA       -1 : 0] tx_data_word;
    reg                         uart_tx_done;
    reg                         tx_8b_start;
    reg                         tx_32b_start;

    word_transmitter u_word_transmitter
    (
        .o_tx_data          (uart_tx_data       ),
        .o_tx_start         (uart_tx_start      ),
        .o_tx_done_8b       (uart_tx_8b_done    ),
        .o_tx_done_32b      (uart_tx_32b_done   ),

        .i_tx_data          (tx_data_word       ),
        .i_tx_done          (uart_tx_done       ),
        .i_tx_8b_start      (tx_8b_start        ),
        .i_tx_32b_start     (tx_32b_start       ),
        .i_reset            (reset              ),
        .i_clock            (clock              )
    );

    initial begin

        tx_data_word = 32'b0;
        uart_tx_done = 1'b0;
        tx_8b_start  = 1'b0;
        tx_32b_start = 1'b0;

        $display("############# Test START ############\n");
        test_startup();

        // send_8b_data_to_word_transmitter(32'hAABBCC55);
        send_32b_data_to_word_transmitter(32'hAABBCC55);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        uart_tx_done = 1'b1;
        @(posedge clock);
        uart_tx_done = 1'b0;

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        uart_tx_done = 1'b1;
        @(posedge clock);
        uart_tx_done = 1'b0;

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        uart_tx_done = 1'b1;
        @(posedge clock);
        uart_tx_done = 1'b0;

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        uart_tx_done = 1'b1;
        @(posedge clock);
        uart_tx_done = 1'b0;

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        // `assert(uart_tx_start == 1'b1);


        #10

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule
