`timescale 1ns / 1ps


module tb_uart_32b_00();

    localparam NB_DATA       = 32;
    localparam NB_REGISTER   = 5;
    localparam NB_STATE      = 3;
    localparam NB_BYTE       = 8;
    localparam N_CLOCKS_BETWEEN_DATA = 4;

    `include "common_defs.v"

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------
    reg  [NB_DATA       -1 : 0] tx_data;
    reg                         tx_start_8b;
    reg                         tx_start_32b;
    wire [NB_STATE      -1 : 0] state;
    wire [NB_DATA       -1 : 0] data_memory;
    wire                        tx_done_8b_pulse;
    wire                        tx_done_32b_pulse;

    uart_32b du_uart_32b
    (
        .o_tx                   (                   ),
        .o_data                 (                   ),
        .o_tx_done_8b_pulse     (tx_done_8b_pulse   ),
        .o_tx_done_32b_pulse    (tx_done_32b_pulse  ),
        .o_rx_done_pulse        (                   ),

        .i_rx                   (                   ),
        .i_tx_data              (tx_data            ),
        .i_tx_start_8b          (tx_start_8b        ),
        .i_tx_start_32b         (tx_start_32b       ),
        .i_reset                (reset              ),
        .i_clock                (clock              )
    );

    initial begin

        tx_data         = 32'b0;
        tx_start_8b     = 1'b0;
        tx_start_32b    = 1'b0;

        $display("############# Test START ############\n");
        test_startup();

        tx_data     = 32'hAABBCCDD;
        tx_start_32b = 1'b1;
        @(posedge clock);
        tx_start_32b = 1'b0;

        repeat (650*16*128) begin
            @(posedge clock);
        end

        @(posedge clock);
        @(posedge clock);

        #10

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule
