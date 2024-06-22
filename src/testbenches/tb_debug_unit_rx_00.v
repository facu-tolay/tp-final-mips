`timescale 1ns / 1ps
`include "common_defs.v"


// Verifica que la FSM pase por los estados

module tb_debug_unit_rx_00();

    localparam NB_DATA       = 32;
    localparam NB_REGISTER   = 5;
    localparam NB_STATE      = 3;
    localparam NB_BYTE       = 8;

    wire [NB_STATE      -1 : 0] state;
    reg  [NB_BYTE       -1 : 0] data_uart_receive;
    reg                         uart_rx_done;

    // --------------------------------------------------
    // Valid block
    // --------------------------------------------------
    reg valid;

    // --------------------------------------------------
    // Clock block
    // --------------------------------------------------
    reg clock;
    always #1 clock = ~clock;

    // --------------------------------------------------
    // Reset block
    // --------------------------------------------------
    reg reset;
    task reset_dut;
        begin
            reset = 1'b1;
            repeat (5) begin
                @(posedge clock);
            end
            reset = 1'b0;
        end
    endtask

    // --------------------------------------------------
    // Test startup
    // --------------------------------------------------
    task test_startup;
        begin
            reset = 1'b0;
            clock = 1'b1;

            reset_dut();

            valid = 1'b1;
        end
    endtask

    // --------------------------------------------------
    // Data Send UART block
    // --------------------------------------------------
    reg rx_data;
    integer i;
    task send_one_bit_uart;
        input wire bit_to_send;
        begin
            // segun un baudrate de 9600 y haciendo de cuenta que el clock es de 100mhz,
            // el tiempo de cada bit es por cada N clocks x M ticks (N=650, M=16)
            rx_data = bit_to_send;
            repeat (650*16) begin
                @(posedge clock);
            end
        end
    endtask

    task send_data_to_rx;
        input [7:0] i_data;

        begin
            send_one_bit_uart(1'b0); // start bit
            for(i=0; i<8; i=i+1) begin
                send_one_bit_uart(i_data[i]);
            end
            send_one_bit_uart(1'b1); // stop bit
        end
    endtask

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
    wire execution_mode;
    wire execution_step;
    wire enable_write_memory;
    wire done_write_memory;
    wire data_memory;

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
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        // check enable_write_memory = true
        // `assert(enable_write_memory == 1'b1);

        // enviar N x 4 bytes y verificar los dones y como se va llenando el data_memory
        send_uart_data_to_du(8'hAA);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        send_uart_data_to_du(8'hBB);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        send_uart_data_to_du(8'hCC);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        send_uart_data_to_du(8'hDD);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        send_uart_data_to_du(8'h11);
        @(posedge clock);
        send_uart_data_to_du(8'h22);
        @(posedge clock);
        @(posedge clock);
        send_uart_data_to_du(8'h33);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        send_uart_data_to_du(8'h44);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        send_uart_data_to_du(8'h1F);
        send_uart_data_to_du(8'h2F);
        send_uart_data_to_du(8'h3F);
        send_uart_data_to_du(8'h4F);

        // envio el halt, verificar que enable_write_memory = 0
        send_uart_data_to_du(8'hFF);
        send_uart_data_to_du(8'hFF);
        send_uart_data_to_du(8'hFF);
        send_uart_data_to_du(8'hFF);

        // enviar el modo de ejecucion
        send_uart_data_to_du(8'h01);
        `assert(enable_write_memory == 1'b0);

        // espera N clocks y despues va mandando pulsos de step
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        send_uart_data_to_du(8'h01);
        @(posedge clock);
        send_uart_data_to_du(8'h01);
        @(posedge clock);


        #10

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule

// `define assert(value) \
//     if (value == 0) begin \
//         $display("ASSERTION EXPECTED TO BE TRUE"); \
//         $display("############# Test [FAILED] ############"); \
//         $finish; \
//     end \